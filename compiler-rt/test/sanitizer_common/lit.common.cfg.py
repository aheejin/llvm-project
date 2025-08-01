# -*- Python -*-

# Setup source root.
config.test_source_root = os.path.join(os.path.dirname(__file__), "TestCases")

config.name = "SanitizerCommon-" + config.name_suffix

default_tool_options = []
collect_stack_traces = ""
if config.tool_name == "asan":
    tool_cflags = ["-fsanitize=address"]
    tool_options = "ASAN_OPTIONS"
elif config.tool_name == "hwasan":
    tool_cflags = ["-fsanitize=hwaddress", "-fuse-ld=lld"]
    if config.target_arch == "x86_64":
        tool_cflags += ["-fsanitize-hwaddress-experimental-aliasing"]
        config.available_features.add("hwasan-aliasing")
    tool_options = "HWASAN_OPTIONS"
    if not config.has_lld:
        config.unsupported = True
elif config.tool_name == "rtsan":
    tool_cflags = ["-fsanitize=realtime"]
    tool_options = "RTSAN_OPTIONS"
elif config.tool_name == "tsan":
    tool_cflags = ["-fsanitize=thread"]
    tool_options = "TSAN_OPTIONS"
elif config.tool_name == "msan":
    tool_cflags = ["-fsanitize=memory"]
    tool_options = "MSAN_OPTIONS"
    collect_stack_traces = "-fsanitize-memory-track-origins"
elif config.tool_name == "lsan":
    tool_cflags = ["-fsanitize=leak"]
    tool_options = "LSAN_OPTIONS"
elif config.tool_name == "ubsan":
    tool_cflags = ["-fsanitize=undefined"]
    tool_options = "UBSAN_OPTIONS"
else:
    lit_config.fatal("Unknown tool for sanitizer_common tests: %r" % config.tool_name)

config.available_features.add(config.tool_name)

if (
    config.target_os == "Linux"
    and config.tool_name == "lsan"
    and config.target_arch == "i386"
):
    config.available_features.add("lsan-x86")

if config.arm_thumb:
    config.available_features.add("thumb")

if config.target_os == "Darwin":
    # On Darwin, we default to `abort_on_error=1`, which would make tests run
    # much slower. Let's override this and run lit tests with 'abort_on_error=0'.
    default_tool_options += ["abort_on_error=0"]
    if config.tool_name == "tsan":
        default_tool_options += ["ignore_interceptors_accesses=0"]
elif config.android:
    # The same as on Darwin, we default to "abort_on_error=1" which slows down
    # testing. Also, all existing tests are using "not" instead of "not --crash"
    # which does not work for abort()-terminated programs.
    default_tool_options += ["abort_on_error=0"]

default_tool_options_str = ":".join(default_tool_options)
if default_tool_options_str:
    config.environment[tool_options] = default_tool_options_str
    default_tool_options_str += ":"

extra_link_flags = []

if config.target_os in ["Linux"]:
    extra_link_flags += ["-ldl"]

clang_cflags = config.debug_info_flags + tool_cflags + [config.target_cflags]
clang_cflags += ["-I%s" % os.path.dirname(os.path.dirname(__file__))]
clang_cflags += extra_link_flags
clang_cxxflags = config.cxx_mode_flags + clang_cflags


def build_invocation(compile_flags):
    return " " + " ".join([config.clang] + compile_flags) + " "


config.substitutions.append(("%clang ", build_invocation(clang_cflags)))
config.substitutions.append(("%clangxx ", build_invocation(clang_cxxflags)))
config.substitutions.append(("%collect_stack_traces", collect_stack_traces))
config.substitutions.append(("%tool_name", config.tool_name))
config.substitutions.append(("%tool_options", tool_options))
config.substitutions.append(
    ("%env_tool_opts=", "%env " + tool_options + "=" + default_tool_options_str)
)

config.suffixes = [".c", ".cpp"]

if config.target_os not in ["Linux", "Darwin", "NetBSD", "FreeBSD", "SunOS"]:
    config.unsupported = True

if not config.parallelism_group:
    config.parallelism_group = "shadow-memory"

if config.target_os == "NetBSD":
    config.substitutions.insert(0, ("%run", config.netbsd_noaslr_prefix))

if os.path.exists("/etc/services"):
    config.available_features.add("netbase")
