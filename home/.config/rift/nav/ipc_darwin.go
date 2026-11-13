package main

/*
#include <mach/mach.h>
#include <servers/bootstrap.h>
#include <string.h>
#include <stdlib.h>

typedef struct {
	mach_msg_header_t header;
	mach_msg_size_t msgh_descriptor_count;
	mach_msg_ool_descriptor_t descriptor;
} borders_message;

// Same message the `borders` client sends (JankyBorders 1.9.0, src/mach.c): one out-of-line buffer of
// NUL-separated arguments, fire and forget. Re-check this if JankyBorders changes its protocol.
static int borders_send(char *payload, unsigned int len) {
	mach_port_t bs_port;
	if (task_get_special_port(mach_task_self(), TASK_BOOTSTRAP_PORT, &bs_port) != KERN_SUCCESS) return -1;
	mach_port_t port;
	if (bootstrap_look_up(bs_port, "git.felix.borders", &port) != KERN_SUCCESS) return -2;
	borders_message msg;
	memset(&msg, 0, sizeof(msg));
	msg.header.msgh_remote_port = port;
	msg.header.msgh_local_port = MACH_PORT_NULL;
	msg.header.msgh_bits = MACH_MSGH_BITS_SET(MACH_MSG_TYPE_COPY_SEND, 0, 0, MACH_MSGH_BITS_COMPLEX);
	msg.header.msgh_size = sizeof(msg);
	msg.msgh_descriptor_count = 1;
	msg.descriptor.address = payload;
	msg.descriptor.size = len;
	msg.descriptor.copy = MACH_MSG_VIRTUAL_COPY;
	msg.descriptor.deallocate = 0;
	msg.descriptor.type = MACH_MSG_OOL_DESCRIPTOR;
	kern_return_t r = mach_msg(&msg.header, MACH_SEND_MSG, sizeof(msg), 0, MACH_PORT_NULL, MACH_MSG_TIMEOUT_NONE, MACH_PORT_NULL);
	return r == KERN_SUCCESS ? 0 : -3;
}
*/
import "C"

import (
	"strings"
	"unsafe"
)

const (
	ipcOK         = 0
	ipcNotRunning = -2
)

// sendBorders hands settings straight to a running JankyBorders. It returns ipcNotRunning when none is registered.
func sendBorders(args []string) int {
	payload := strings.Join(args, "\x00") + "\x00\x00"
	buf := C.CString(payload)
	defer C.free(unsafe.Pointer(buf))
	return int(C.borders_send(buf, C.uint(len(payload))))
}
