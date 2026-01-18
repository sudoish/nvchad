return {
  trees_folder = ".trees",
  default_ai_tool = "claude",
  git_flow = {
    enabled = true,
    default_type = "feature",
    types = {
      "feature",
      "bugfix",
      "hotfix",
      "release",
      "support",
    },
  },
  notifications = {
    success = true,
    errors = true,
  },
}
