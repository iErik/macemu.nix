/* Minimal userspace <scsi/sg.h> for macemu (SG driver ioctls + sg_header).
 * Linux uapi no longer ships this header; see linux/include/scsi/sg.h (older trees).
 */
#ifndef SCSI_SG_MACEMU_H
#define SCSI_SG_MACEMU_H

#define SG_MAX_SENSE 16

struct sg_header {
  int pack_len;
  int reply_len;
  int pack_id;
  int result;
  unsigned int twelve_byte : 1;
  unsigned int target_status : 5;
  unsigned int host_status : 8;
  unsigned int driver_status : 8;
  unsigned int other_flags : 10;
  unsigned char sense_buffer[SG_MAX_SENSE];
};

#define DRIVER_SENSE 0x08

#define SG_SET_TIMEOUT 0x2201
#define SG_GET_TIMEOUT 0x2202
#define SG_NEXT_CMD_LEN 0x2283

#endif
