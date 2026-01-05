local M = {}

package.path = package.path .. ";./lua/?.lua"

describe("Slugify Utility", function()
  local slugify

  before_each(function()
    package.loaded["utils.slugify"] = nil
    slugify = require "utils.slugify"
  end)

  it("should load the module", function()
    assert.is_table(slugify, "module should be a table")
  end)

  it("should have slugify function", function()
    assert.is_function(slugify.slugify, "should have slugify function")
  end)

  describe("basic functionality", function()
    it("should convert simple text to lowercase hyphenated", function()
      local result = slugify.slugify "Build new feature"
      assert.equals("build-new-fea...", result, "should convert to hyphenated and truncate")
    end)

    it("should handle single words", function()
      local result = slugify.slugify "Hello"
      assert.equals("hello", result, "should handle single word")
    end)

    it("should handle numbers", function()
      local result = slugify.slugify "Test 123"
      assert.equals("test-123", result, "should preserve numbers")
    end)

    it("should remove extra spaces", function()
      local result = slugify.slugify "Test   multiple   spaces"
      assert.equals("test-multiple...", result, "should collapse multiple spaces")
    end)
  end)

  describe("truncation", function()
    it("should truncate long strings to 15 chars plus ...", function()
      local result = slugify.slugify "This is a very long title that should be truncated"
      assert.equals("this-is-a-ver...", result, "should truncate to 15 chars")
    end)

    it("should not truncate short strings", function()
      local result = slugify.slugify "short text"
      assert.equals("short-text", result, "should not truncate short strings")
    end)

    it("should handle exactly 15 chars", function()
      local result = slugify.slugify "fifteenchars123"
      assert.equals("fifteenchars123", result, "should not truncate exactly 15 chars")
    end)

    it("should handle 16 chars", function()
      local result = slugify.slugify "sixteenchars1234"
      assert.equals("sixteenchars12...", result, "should truncate 16 chars")
    end)
  end)

  describe("special characters", function()
    it("should convert special characters to hyphens", function()
      local result = slugify.slugify "Test@Special#Chars"
      assert.equals("test-special-...", result, "should handle special chars")
    end)

    it("should handle underscores", function()
      local result = slugify.slugify "test_with_underscores"
      assert.equals("test-with-unde...", result, "should convert underscores to hyphens")
    end)

    it("should handle dots", function()
      local result = slugify.slugify "test.with.dots"
      assert.equals("test-with-dot...", result, "should convert dots to hyphens")
    end)

    it("should handle mixed special chars", function()
      local result = slugify.slugify "Hello! World? How are you?"
      assert.equals("hello-world-ho...", result, "should handle punctuation")
    end)
  end)

  describe("unicode handling", function()
    it("should handle basic unicode characters", function()
      local result = slugify.slugify "Test café"
      assert.equals("test-cafe", result, "should handle basic unicode")
    end)

    it("should handle unicode emojis", function()
      local result = slugify.slugify "Test 🚀 feature"
      assert.equals("test-feature", result, "should handle emojis")
    end)

    it("should handle accented characters", function()
      local result = slugify.slugify "Äpfel örneß"
      assert.equals("pfel-rne", result, "should handle accents")
    end)
  end)

  describe("edge cases", function()
    it("should handle empty string", function()
      local result = slugify.slugify ""
      assert.equals("", result, "should return empty string for empty input")
    end)

    it("should handle nil input", function()
      local result = slugify.slugify(nil)
      assert.equals("", result, "should return empty string for nil")
    end)

    it("should handle only special characters", function()
      local result = slugify.slugify "@#$%^&*()"
      assert.equals("", result, "should return empty string")
    end)

    it("should handle only spaces", function()
      local result = slugify.slugify "     "
      assert.equals("", result, "should return empty string for only spaces")
    end)

    it("should handle leading/trailing spaces", function()
      local result = slugify.slugify "  test string  "
      assert.equals("test-string", result, "should trim spaces")
    end)

    it("should handle leading/trailing special chars", function()
      local result = slugify.slugify "-test-string-"
      assert.equals("test-string", result, "should trim leading/trailing hyphens")
    end)

    it("should handle multiple consecutive hyphens", function()
      local result = slugify.slugify "test---string"
      assert.equals("test-string", result, "should collapse consecutive hyphens")
    end)
  end)

  describe("case handling", function()
    it("should convert to lowercase", function()
      local result = slugify.slugify "UPPERCASE TEXT"
      assert.equals("uppercase-tex...", result, "should convert to lowercase")
    end)

    it("should handle mixed case", function()
      local result = slugify.slugify "MiXeD CaSe TeXt"
      assert.equals("mixed-case-te...", result, "should handle mixed case")
    end)
  end)
end)

return M
