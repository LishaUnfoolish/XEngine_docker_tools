add_rules("mode.debug", "mode.release")

target("${TARGETNAME}")
    add_rules("xcode.framework")
    add_files("src/*.mm")
    add_files("src/Info.plist")
    add_headerfiles("src/*.h")

${FAQ}
