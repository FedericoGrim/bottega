return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "rcasia/neotest-java",
      "nvim-neotest/neotest-jest",
      "marilari88/neotest-vitest",
    },
    opts = {
      adapters = {
        ["neotest-java"] = {},
        ["neotest-jest"] = {},
        ["neotest-vitest"] = {},
      },
    },
  },
}
