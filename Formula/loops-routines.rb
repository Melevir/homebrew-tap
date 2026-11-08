class LoopsRoutines < Formula
  desc "Run Claude Code routines on a schedule within your plan's usage limits"
  homepage "https://github.com/Melevir/loops-routines"
  url "https://files.pythonhosted.org/packages/1a/93/a1f94b204845b24ddde667c195de19647ebe5235839debd5e87d06474281/loops_routines-0.1.0.tar.gz"
  sha256 "72d7dfbc6504eec7916bdd669eb9ea38a901ea717f80f24bd8ebb4ff4a668dea"
  license "MIT"

  depends_on :macos
  depends_on "python@3.14"

  def install
    python = formula_opt_bin("python@3.14")/"python3.14"
    system python, "-m", "venv", libexec
    # Dependencies come from PyPI as wheels: pydantic-core and rpds-py would otherwise need a Rust build.
    system libexec/"bin/python", "-m", "pip", "install", "--no-cache-dir", "--disable-pip-version-check", buildpath
    bin.install_symlink libexec/"bin/loops-routines"
  end

  def caveats
    <<~EOS
      Set up ~/.loops_routines, start the daemon at login and add its MCP server to Claude Code:
        loops-routines install --launchd --mcp

      After `brew upgrade loops-routines`, restart the daemon so it runs the new version:
        loops-routines restart

      Needs Claude Code (`claude` on your PATH, signed in).
    EOS
  end

  test do
    (testpath/"daily.md").write <<~EOS
      +++
      schedule = "0 9 * * *"
      +++
      Say hello.
    EOS
    assert_match "daily: ok", shell_output("#{bin}/loops-routines check #{testpath}/daily.md")
  end
end
