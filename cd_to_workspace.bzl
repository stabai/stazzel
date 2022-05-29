# Based on https://stackoverflow.com/a/65129568/1819467

def _cd_to_workspace_impl(ctx):
    src = ctx.files._src[0]
    out = ctx.actions.declare_file(ctx.label.name)
    ctx.actions.run_shell(
        inputs = ctx.files._src,
        outputs = [out],
        command = """
          full_path="$(readlink -f -- "{src_full}")"
          # Trim the src.short_path suffix from full_path. Double braces to
          # output literal brace for shell.
          echo "cd ${{full_path%/{src_short}}}" >> {out_full}
        """.format(src_full = src.path, src_short = src.short_path, out_full = out.path),
        execution_requirements = {
            "no-sandbox": "1",
            "no-remote": "1",
            "local": "1",
        },
    )
    return [DefaultInfo(executable = out, files = depset([out]))]

cd_to_workspace = rule(
    implementation = _run_in_workspace_impl,
    executable = True,
    attrs = {
        "_src": attr.label(allow_files = True, default = "BUILD.bazel"),
    },
    doc = "Writes a shell script that will cd into the root directory of the current workspace.",
)
