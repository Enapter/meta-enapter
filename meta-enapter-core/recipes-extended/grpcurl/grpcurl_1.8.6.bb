SUMMARY = "Command-line tool that lets you interact with gRPC servers"
DESCRIPTION = "${SUMMARY}"
HOMEPAGE = "https://github.com/fullstorydev/grpcurl"

GO_IMPORT = "github.com/fullstorydev/grpcurl"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${S}/src/${GO_IMPORT}/LICENSE;md5=43d9662feb52d5a750ba4668f5a08f6b"

GO_INSTALL = "${GO_IMPORT}/cmd/grpcurl"

SRC_URI = "git://${GO_IMPORT}.git;branch=master;protocol=https"
SRCREV = "0d0992e6a2c94948189e84e5f599773eceaba4db"

inherit go-mod

RDEPENDS:${PN}-dev += "bash"
INSANE_SKIP:${PN} = "ldflags"
