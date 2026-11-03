import importlib.machinery
import importlib.util
import re
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

sys.dont_write_bytecode = True

DOCS_PATH = Path(__file__).resolve().parent.parent / "bin" / "dev-docs"
ANSI_ESCAPE = re.compile(r"\x1b\[[0-9;]*m")

GIT_SHEET = """# Git

Some prose that is ignored.

## Branch

| Comando | Cosa fa |
| --- | --- |
| `git switch -c nome` | crea un branch e ci passa |
| `git branch -d nome` | elimina un branch `unito` |

## Storia

| Comando | Cosa fa |
|:---|---:|
| `git log --oneline \\| head` | ultimi commit, uno per riga |
"""

TMUX_SHEET = """# tmux

## Pannelli

| Tasto | Cosa fa |
| --- | --- |
| `Ctrl+b z` | ingrandisce il pannello |
"""


def load_docs():
    loader = importlib.machinery.SourceFileLoader("dev_docs", str(DOCS_PATH))
    spec = importlib.util.spec_from_loader("dev_docs", loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


def plain(text):
    return ANSI_ESCAPE.sub("", text)


class ParseCheatsheetTest(unittest.TestCase):
    def setUp(self):
        self.docs = load_docs()
        self.topic = self.docs.parse_cheatsheet(GIT_SHEET)

    def test_reads_the_title(self):
        self.assertEqual(self.topic.title, "Git")

    def test_reads_one_entry_per_table_row_skipping_headers(self):
        commands = [entry.command for entry in self.topic.entries]
        self.assertEqual(commands, ["git switch -c nome", "git branch -d nome", "git log --oneline | head"])

    def test_keeps_the_section_of_each_entry(self):
        sections = [entry.section for entry in self.topic.entries]
        self.assertEqual(sections, ["Branch", "Branch", "Storia"])

    def test_keeps_a_backtick_that_is_the_command_itself(self):
        topic = self.docs.parse_cheatsheet("| Tasto | Cosa fa |\n| --- | --- |\n| `` ` `` | cambia vista |\n")
        self.assertEqual(topic.entries[0].command, "`")

    def test_removes_backticks_from_descriptions(self):
        self.assertEqual(self.topic.entries[1].description, "elimina un branch unito")


class LoadTopicsTest(unittest.TestCase):
    def setUp(self):
        self.docs = load_docs()
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        folder = Path(self.directory.name)
        (folder / "tmux.md").write_text(TMUX_SHEET)
        (folder / "git.md").write_text(GIT_SHEET)
        (folder / "notes.txt").write_text("not a cheatsheet")

    def test_loads_every_markdown_file_sorted_by_title(self):
        topics = self.docs.load_topics(Path(self.directory.name))
        self.assertEqual([topic.title for topic in topics], ["Git", "tmux"])

    def test_missing_directory_gives_no_topics(self):
        self.assertEqual(self.docs.load_topics(Path(self.directory.name) / "missing"), [])


class FormatRowsTest(unittest.TestCase):
    def setUp(self):
        self.docs = load_docs()
        self.topics = [self.docs.parse_cheatsheet(GIT_SHEET), self.docs.parse_cheatsheet(TMUX_SHEET)]

    def rows(self, selected):
        return self.docs.format_rows(self.topics, selected).splitlines()

    def test_first_line_is_the_topic_bar(self):
        bar = plain(self.rows(0)[0].split("\t")[2])
        for name in ("Tutti", "Git", "tmux"):
            self.assertIn(name, bar)

    def test_all_topics_show_every_entry_with_its_topic(self):
        lines = self.rows(0)[1:]
        self.assertEqual(len(lines), 4)
        self.assertIn("tmux › Pannelli", plain(lines[-1]))

    def test_a_single_topic_shows_only_its_entries(self):
        lines = self.rows(2)[1:]
        self.assertEqual([line.split("\t")[0] for line in lines], ["Ctrl+b z"])

    def test_hidden_fields_hold_command_and_description(self):
        command, description, _ = self.rows(1)[1].split("\t")
        self.assertEqual((command, description), ("git switch -c nome", "crea un branch e ci passa"))

    def test_descriptions_start_in_the_same_column(self):
        displays = [plain(line.split("\t")[2]) for line in self.rows(1)[1:]]
        columns = {display.index(entry.description) for display, entry in zip(displays, self.topics[0].entries)}
        self.assertEqual(len(columns), 1)


class TopicStateTest(unittest.TestCase):
    def setUp(self):
        self.docs = load_docs()
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.state_file = Path(self.directory.name) / "state"

    def test_starts_from_all_topics(self):
        self.assertEqual(self.docs.read_selected_topic(self.state_file), 0)

    def test_moving_wraps_around_both_ends(self):
        self.assertEqual(self.docs.move_selected_topic(self.state_file, -1, 3), 2)
        self.assertEqual(self.docs.move_selected_topic(self.state_file, 1, 3), 0)
        self.assertEqual(self.docs.read_selected_topic(self.state_file), 0)


class CopyToClipboardTest(unittest.TestCase):
    def setUp(self):
        self.docs = load_docs()

    def copy_with(self, available, environment):
        def which(name):
            return f"/usr/bin/{name}" if name in available else None

        with (
            mock.patch.object(self.docs.shutil, "which", side_effect=which),
            mock.patch.dict(self.docs.os.environ, environment, clear=True),
            mock.patch.object(self.docs.subprocess, "run") as run,
        ):
            self.docs.copy_to_clipboard("git status")
        return run.call_args.args[0], run.call_args.kwargs

    def test_uses_xclip_on_x11(self):
        command, options = self.copy_with({"xclip", "wl-copy"}, {"DISPLAY": ":0"})
        self.assertEqual(command, ["xclip", "-selection", "clipboard"])
        self.assertEqual(options["input"], "git status")

    def test_uses_wl_copy_on_wayland(self):
        command, _ = self.copy_with({"xclip", "wl-copy"}, {"WAYLAND_DISPLAY": "wayland-0", "DISPLAY": ":0"})
        self.assertEqual(command, ["wl-copy"])

    def test_falls_back_to_the_tmux_clipboard(self):
        command, _ = self.copy_with(set(), {"DISPLAY": ":0"})
        self.assertEqual(command, ["tmux", "set-buffer", "-w", "--", "git status"])


if __name__ == "__main__":
    unittest.main()
