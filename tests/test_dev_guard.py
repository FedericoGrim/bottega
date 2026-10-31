import importlib.machinery
import importlib.util
import io
import json
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock

sys.dont_write_bytecode = True

GUARD_PATH = Path(__file__).resolve().parent.parent / "bin" / "dev-guard"


def load_guard():
    loader = importlib.machinery.SourceFileLoader("dev_guard", str(GUARD_PATH))
    spec = importlib.util.spec_from_loader("dev_guard", loader)
    module = importlib.util.module_from_spec(spec)
    loader.exec_module(module)
    return module


class GuardTestCase(unittest.TestCase):
    def setUp(self):
        self.guard = load_guard()
        self.home = tempfile.TemporaryDirectory()
        self.project = tempfile.TemporaryDirectory(prefix="my.project")
        self.addCleanup(self.home.cleanup)
        self.addCleanup(self.project.cleanup)
        env = {"HOME": self.home.name, "CLAUDE_PROJECT_DIR": self.project.name}
        patcher = mock.patch.dict(os.environ, env)
        patcher.start()
        self.addCleanup(patcher.stop)

    def enable_container(self):
        name = os.path.basename(os.path.realpath(self.project.name)).translate(
            str.maketrans(".:", "__")
        )
        state_dir = Path(self.home.name) / ".cache" / "dev"
        state_dir.mkdir(parents=True)
        (state_dir / f"{name}.json").write_text("{}")

    def run_guard(self, payload):
        stdin = io.StringIO(
            payload if isinstance(payload, str) else json.dumps(payload)
        )
        stderr = io.StringIO()
        with mock.patch("sys.stdin", stdin), mock.patch("sys.stderr", stderr):
            code = self.guard.main()
        return code, stderr.getvalue()

    def bash(self, command):
        return self.run_guard({"tool_name": "Bash", "tool_input": {"command": command}})

    def assertAllowed(self, command):
        code, message = self.bash(command)
        self.assertEqual(code, 0, f"expected allowed: {command!r} -> {message}")

    def assertBlocked(self, command):
        code, message = self.bash(command)
        self.assertEqual(code, 2, f"expected blocked: {command!r}")
        self.assertIn("dev-in", message)


class ProjectWithoutContainerTest(GuardTestCase):
    def test_allows_everything_when_project_has_no_container(self):
        self.assertAllowed("pip install requests")


class ProjectWithContainerTest(GuardTestCase):
    def setUp(self):
        super().setUp()
        self.enable_container()

    def test_allows_commands_routed_through_dev_in(self):
        self.assertAllowed("dev-in npm test")

    def test_allows_read_only_host_commands(self):
        for command in ["git status", "ls -la", "rg TODO src", "cat README.md", "pwd"]:
            with self.subTest(command=command):
                self.assertAllowed(command)

    def test_allows_pipelines_of_safe_commands(self):
        self.assertAllowed("git log --oneline | head -5")

    def test_allows_cd_before_dev_in(self):
        self.assertAllowed("cd src && dev-in ls")

    def test_allows_environment_assignment_before_command(self):
        self.assertAllowed("CI=1 dev-in make test")

    def test_blocks_package_installs_on_the_host(self):
        for command in [
            "pip install requests",
            "python3 -m pip install requests",
            "npm install",
            "sudo apt install curl",
            "bash -c 'pip install x'",
        ]:
            with self.subTest(command=command):
                self.assertBlocked(command)

    def test_blocks_when_any_chained_segment_is_unsafe(self):
        self.assertBlocked("dev-in npm test && pip install x")
        self.assertBlocked("ls; rm -rf build")
        self.assertBlocked("git status || npm install")
        self.assertBlocked("ls\nnpm install")

    def test_blocks_command_substitution(self):
        self.assertBlocked("echo $(pip install x)")
        self.assertBlocked('echo "$(pip install x)"')
        self.assertBlocked("echo `pip install x`")

    def test_single_quotes_hide_substitution_syntax(self):
        self.assertAllowed("echo '$(pip install x)'")

    def test_separators_inside_quotes_do_not_split(self):
        self.assertAllowed('echo "a; b && c"')

    def test_allows_git_commit_message_heredoc(self):
        command = "git commit -m \"$(cat <<'EOF'\nfeat: add thing\n\nbody\nEOF\n)\""
        self.assertAllowed(command)

    def test_blocks_heredoc_substitution_with_trailing_unsafe_command(self):
        command = "git commit -m \"$(cat <<'EOF'\nmsg\nEOF\n)\" && pip install x"
        self.assertBlocked(command)

    def test_blocks_unbalanced_quotes(self):
        self.assertBlocked("echo 'unterminated")

    def test_allows_empty_command(self):
        self.assertAllowed("")


class ToolAndInputHandlingTest(GuardTestCase):
    def setUp(self):
        super().setUp()
        self.enable_container()

    def test_ignores_non_bash_tools(self):
        code, _ = self.run_guard(
            {"tool_name": "Read", "tool_input": {"file_path": "x"}}
        )
        self.assertEqual(code, 0)

    def test_fails_closed_on_malformed_json(self):
        code, message = self.run_guard("not json")
        self.assertEqual(code, 2)
        self.assertIn("dev-guard", message)

    def test_fails_closed_when_command_is_not_a_string(self):
        code, _ = self.run_guard({"tool_name": "Bash", "tool_input": {"command": 42}})
        self.assertEqual(code, 2)

    def test_falls_back_to_payload_cwd_without_project_dir_variable(self):
        with mock.patch.dict(os.environ):
            os.environ.pop("CLAUDE_PROJECT_DIR")
            payload = {
                "tool_name": "Bash",
                "cwd": self.project.name,
                "tool_input": {"command": "pip install x"},
            }
            code, _ = self.run_guard(payload)
        self.assertEqual(code, 2)


class InstallHookTest(GuardTestCase):
    def settings_path(self):
        return Path(self.project.name) / ".claude" / "settings.local.json"

    def test_creates_settings_with_hook_and_permission(self):
        self.guard.install_hook(self.project.name)
        settings = json.loads(self.settings_path().read_text())
        hook_commands = [
            handler["command"]
            for group in settings["hooks"]["PreToolUse"]
            for handler in group["hooks"]
        ]
        self.assertEqual(hook_commands, ['"$HOME/.local/bin/dev-guard"'])
        self.assertIn("Bash(dev-in:*)", settings["permissions"]["allow"])

    def test_install_is_idempotent_and_keeps_existing_settings(self):
        path = self.settings_path()
        path.parent.mkdir(parents=True)
        path.write_text(
            json.dumps({"permissions": {"allow": ["Bash(ls:*)"]}, "model": "x"})
        )
        self.guard.install_hook(self.project.name)
        self.guard.install_hook(self.project.name)
        settings = json.loads(path.read_text())
        self.assertEqual(settings["model"], "x")
        self.assertEqual(settings["permissions"]["allow"].count("Bash(ls:*)"), 1)
        self.assertEqual(settings["permissions"]["allow"].count("Bash(dev-in:*)"), 1)
        self.assertEqual(len(settings["hooks"]["PreToolUse"]), 1)


if __name__ == "__main__":
    unittest.main()
