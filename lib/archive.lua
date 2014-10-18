local ffi = require("ffi")
local lib = ffi.load("archive")
local bit = require("bit")

local M = {}
M.ARCHIVE_VERSION_NUMBER =  3001002
M.ARCHIVE_VERSION_STRING =  "libarchive 3.1.2"

if M.ARCHIVE_VERSION_NUMBER >= 3999000 then
    ffi.cdef("typedef int la_mode_t;")   
else
    ffi.cdef("typedef uint16_t la_mode_t;")
end
ffi.cdef[[
typedef long int la_time_t;
typedef uint64_t la_dev_t;
typedef intptr_t la_ssize_t;
]]

local header = [[
/*-
 * Copyright (c) 2003-2010 Tim Kientzle
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR(S) ``AS IS'' AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 * IN NO EVENT SHALL THE AUTHOR(S) BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * $FreeBSD: src/lib/libarchive/archive.h.in,v 1.50 2008/05/26 17:00:22 kientzle Exp $
 */


int     archive_version_number(void);

const char *    archive_version_string(void);

struct archive;
struct archive_entry;

typedef la_ssize_t  archive_read_callback(struct archive *, void *_client_data, const void **_buffer);

typedef int64_t archive_skip_callback(struct archive *, void *_client_data, int64_t request);

typedef int64_t archive_seek_callback(struct archive *, void *_client_data, int64_t offset, int whence);

typedef la_ssize_t  archive_write_callback(struct archive *, void *_client_data, const void *_buffer, size_t _length);

typedef int archive_open_callback(struct archive *, void *_client_data);

typedef int archive_close_callback(struct archive *, void *_client_data);

typedef int archive_switch_callback(struct archive *, void *_client_data1, void *_client_data2);

struct archive  *archive_read_new(void);

int archive_read_support_filter_all(struct archive *);
int archive_read_support_filter_bzip2(struct archive *);
int archive_read_support_filter_compress(struct archive *);
int archive_read_support_filter_gzip(struct archive *);
int archive_read_support_filter_grzip(struct archive *);
int archive_read_support_filter_lrzip(struct archive *);
int archive_read_support_filter_lzip(struct archive *);
int archive_read_support_filter_lzma(struct archive *);
int archive_read_support_filter_lzop(struct archive *);
int archive_read_support_filter_none(struct archive *);
int archive_read_support_filter_program(struct archive *, const char *command);
int archive_read_support_filter_program_signature
        (struct archive *, const char * /* cmd */, const void * /* match */, size_t);
int archive_read_support_filter_rpm(struct archive *);
int archive_read_support_filter_uu(struct archive *);
int archive_read_support_filter_xz(struct archive *);

int archive_read_support_format_7zip(struct archive *);
int archive_read_support_format_all(struct archive *);
int archive_read_support_format_ar(struct archive *);
int archive_read_support_format_by_code(struct archive *, int);
int archive_read_support_format_cab(struct archive *);
int archive_read_support_format_cpio(struct archive *);
int archive_read_support_format_empty(struct archive *);
int archive_read_support_format_gnutar(struct archive *);
int archive_read_support_format_iso9660(struct archive *);
int archive_read_support_format_lha(struct archive *);
int archive_read_support_format_mtree(struct archive *);
int archive_read_support_format_rar(struct archive *);
int archive_read_support_format_raw(struct archive *);
int archive_read_support_format_tar(struct archive *);
int archive_read_support_format_xar(struct archive *);
int archive_read_support_format_zip(struct archive *);

int archive_read_set_format(struct archive *, int);
int archive_read_append_filter(struct archive *, int);
int archive_read_append_filter_program(struct archive *, const char *);
int archive_read_append_filter_program_signature
    (struct archive *, const char *, const void * /* match */, size_t);

int archive_read_set_open_callback(struct archive *, archive_open_callback *);
int archive_read_set_read_callback(struct archive *, archive_read_callback *);
int archive_read_set_seek_callback(struct archive *, archive_seek_callback *);
int archive_read_set_skip_callback(struct archive *, archive_skip_callback *);
int archive_read_set_close_callback(struct archive *, archive_close_callback *);
int archive_read_set_switch_callback(struct archive *, archive_switch_callback *);

int archive_read_set_callback_data(struct archive *, void *);
int archive_read_set_callback_data2(struct archive *, void *, unsigned int);
int archive_read_add_callback_data(struct archive *, void *, unsigned int);
int archive_read_append_callback_data(struct archive *, void *);
int archive_read_prepend_callback_data(struct archive *, void *);

int archive_read_open1(struct archive *);

int archive_read_open(struct archive *, void *_client_data, archive_open_callback *, archive_read_callback *, archive_close_callback *);
int archive_read_open2(struct archive *, void *_client_data, archive_open_callback *, archive_read_callback *, archive_skip_callback *, archive_close_callback *);

int archive_read_open_filename(struct archive *, const char *_filename, size_t _block_size);
int archive_read_open_filenames(struct archive *, const char **_filenames, size_t _block_size);
int archive_read_open_filename_w(struct archive *, const wchar_t *_filename, size_t _block_size);
int archive_read_open_memory(struct archive *, void * buff, size_t size);
int archive_read_open_memory2(struct archive *a, void *buff, size_t size, size_t read_size);
int archive_read_open_fd(struct archive *, int _fd, size_t _block_size);

int archive_read_next_header(struct archive *, struct archive_entry **);

int archive_read_next_header2(struct archive *, struct archive_entry *);

int64_t      archive_read_header_position(struct archive *);

la_ssize_t       archive_read_data(struct archive *, void *, size_t);

int64_t archive_seek_data(struct archive *, int64_t, int);

int archive_read_data_block(struct archive *a, const void **buff, size_t *size, int64_t *offset);

int archive_read_data_skip(struct archive *);
int archive_read_data_into_fd(struct archive *, int fd);

int archive_read_set_format_option(struct archive *_a, const char *m, const char *o, const char *v);
int archive_read_set_filter_option(struct archive *_a, const char *m, const char *o, const char *v);
int archive_read_set_option(struct archive *_a, const char *m, const char *o, const char *v);
int archive_read_set_options(struct archive *_a, const char *opts);

int archive_read_extract(struct archive *, struct archive_entry *, int flags);
int archive_read_extract2(struct archive *, struct archive_entry *, struct archive * /* dest */);
void     archive_read_extract_set_progress_callback(struct archive *, void (*_progress_func)(void *), void *_user_data);

void        archive_read_extract_set_skip_file(struct archive *, int64_t, int64_t);

int      archive_read_close(struct archive *);
int      archive_read_free(struct archive *);

struct archive  *archive_write_new(void);
int archive_write_set_bytes_per_block(struct archive *, int bytes_per_block);
int archive_write_get_bytes_per_block(struct archive *);
int archive_write_set_bytes_in_last_block(struct archive *, int bytes_in_last_block);
int archive_write_get_bytes_in_last_block(struct archive *);

int archive_write_set_skip_file(struct archive *, int64_t, int64_t);

int archive_write_add_filter(struct archive *, int filter_code);
int archive_write_add_filter_by_name(struct archive *, const char *name);
int archive_write_add_filter_b64encode(struct archive *);
int archive_write_add_filter_bzip2(struct archive *);
int archive_write_add_filter_compress(struct archive *);
int archive_write_add_filter_grzip(struct archive *);
int archive_write_add_filter_gzip(struct archive *);
int archive_write_add_filter_lrzip(struct archive *);
int archive_write_add_filter_lzip(struct archive *);
int archive_write_add_filter_lzma(struct archive *);
int archive_write_add_filter_lzop(struct archive *);
int archive_write_add_filter_none(struct archive *);
int archive_write_add_filter_program(struct archive *, const char *cmd);
int archive_write_add_filter_uuencode(struct archive *);
int archive_write_add_filter_xz(struct archive *);

int archive_write_set_format(struct archive *, int format_code);
int archive_write_set_format_by_name(struct archive *, const char *name);
int archive_write_set_format_7zip(struct archive *);
int archive_write_set_format_ar_bsd(struct archive *);
int archive_write_set_format_ar_svr4(struct archive *);
int archive_write_set_format_cpio(struct archive *);
int archive_write_set_format_cpio_newc(struct archive *);
int archive_write_set_format_gnutar(struct archive *);
int archive_write_set_format_iso9660(struct archive *);
int archive_write_set_format_mtree(struct archive *);
int archive_write_set_format_mtree_classic(struct archive *);
int archive_write_set_format_pax(struct archive *);
int archive_write_set_format_pax_restricted(struct archive *);
int archive_write_set_format_shar(struct archive *);
int archive_write_set_format_shar_dump(struct archive *);
int archive_write_set_format_ustar(struct archive *);
int archive_write_set_format_v7tar(struct archive *);
int archive_write_set_format_xar(struct archive *);
int archive_write_set_format_zip(struct archive *);
int archive_write_zip_set_compression_deflate(struct archive *);
int archive_write_zip_set_compression_store(struct archive *);
int archive_write_open(struct archive *, void *, archive_open_callback *, archive_write_callback *, archive_close_callback *);
int archive_write_open_fd(struct archive *, int _fd);
int archive_write_open_filename(struct archive *, const char *_file);
int archive_write_open_filename_w(struct archive *, const wchar_t *_file);
int archive_write_open_memory(struct archive *, void *_buffer, size_t _buffSize, size_t *_used);

int archive_write_header(struct archive *, struct archive_entry *);
la_ssize_t  archive_write_data(struct archive *, const void *, size_t);

la_ssize_t   archive_write_data_block(struct archive *, const void *, size_t, int64_t);

int      archive_write_finish_entry(struct archive *);
int      archive_write_close(struct archive *);
int            archive_write_fail(struct archive *);
int      archive_write_free(struct archive *);

int archive_write_set_format_option(struct archive *_a, const char *m, const char *o, const char *v);
int archive_write_set_filter_option(struct archive *_a, const char *m, const char *o, const char *v);
int archive_write_set_option(struct archive *_a, const char *m, const char *o, const char *v);
int archive_write_set_options(struct archive *_a, const char *opts);

struct archive  *archive_write_disk_new(void);
int archive_write_disk_set_skip_file(struct archive *, int64_t, int64_t);
int      archive_write_disk_set_options(struct archive *, int flags);
int  archive_write_disk_set_standard_lookup(struct archive *);
int archive_write_disk_set_group_lookup(struct archive *, void * /* private_data */, int64_t (*)(void *, const char *, int64_t), void (* /* cleanup */)(void *));
int archive_write_disk_set_user_lookup(struct archive *, void * /* private_data */, int64_t (*)(void *, const char *, int64_t), void (* /* cleanup */)(void *));
int64_t archive_write_disk_gid(struct archive *, const char *, int64_t);
int64_t archive_write_disk_uid(struct archive *, const char *, int64_t);

struct archive *archive_read_disk_new(void);
int archive_read_disk_set_symlink_logical(struct archive *);
int archive_read_disk_set_symlink_physical(struct archive *);
int archive_read_disk_set_symlink_hybrid(struct archive *);
int archive_read_disk_entry_from_file(struct archive *, struct archive_entry *, int /* fd */, const struct stat *);
const char *archive_read_disk_gname(struct archive *, int64_t);
const char *archive_read_disk_uname(struct archive *, int64_t);
int archive_read_disk_set_standard_lookup(struct archive *);
int archive_read_disk_set_gname_lookup(struct archive *, void * /* private_data */, const char *(* /* lookup_fn */)(void *, int64_t), void (* /* cleanup_fn */)(void *));
int archive_read_disk_set_uname_lookup(struct archive *, void * /* private_data */, const char *(* /* lookup_fn */)(void *, int64_t), void (* /* cleanup_fn */)(void *));
int archive_read_disk_open(struct archive *, const char *);
int archive_read_disk_open_w(struct archive *, const wchar_t *);
int archive_read_disk_descend(struct archive *);
int archive_read_disk_can_descend(struct archive *);
int archive_read_disk_current_filesystem(struct archive *);
int archive_read_disk_current_filesystem_is_synthetic(struct archive *);
int archive_read_disk_current_filesystem_is_remote(struct archive *);
int  archive_read_disk_set_atime_restored(struct archive *);

int  archive_read_disk_set_behavior(struct archive *, int flags);

int archive_read_disk_set_matching(struct archive *, struct archive *_matching, void (*_excluded_func)
            (struct archive *, void *, struct archive_entry *), void *_client_data);
int archive_read_disk_set_metadata_filter_callback(struct archive *, int (*_metadata_filter_func)(struct archive *, void *, struct archive_entry *), void *_client_data);

int      archive_filter_count(struct archive *);
int64_t  archive_filter_bytes(struct archive *, int);
int      archive_filter_code(struct archive *, int);
const char *     archive_filter_name(struct archive *, int);

int      archive_errno(struct archive *);
const char  *archive_error_string(struct archive *);
const char  *archive_format_name(struct archive *);
int      archive_format(struct archive *);
void         archive_clear_error(struct archive *);
void         archive_set_error(struct archive *, int _err, const char *fmt, ...);
void         archive_copy_error(struct archive *dest, struct archive *src);
int      archive_file_count(struct archive *);

struct archive *archive_match_new(void);
int archive_match_free(struct archive *);

int archive_match_excluded(struct archive *, struct archive_entry *);

int archive_match_path_excluded(struct archive *, struct archive_entry *);
int archive_match_exclude_pattern(struct archive *, const char *);
int archive_match_exclude_pattern_w(struct archive *, const wchar_t *);
int archive_match_exclude_pattern_from_file(struct archive *, const char *, int _nullSeparator);
int archive_match_exclude_pattern_from_file_w(struct archive *, const wchar_t *, int _nullSeparator);
int archive_match_include_pattern(struct archive *, const char *);
int archive_match_include_pattern_w(struct archive *, const wchar_t *);
int archive_match_include_pattern_from_file(struct archive *, const char *, int _nullSeparator);
int archive_match_include_pattern_from_file_w(struct archive *, const wchar_t *, int _nullSeparator);
int archive_match_path_unmatched_inclusions(struct archive *);
int archive_match_path_unmatched_inclusions_next(
            struct archive *, const char **);
int archive_match_path_unmatched_inclusions_next_w(
            struct archive *, const wchar_t **);

int archive_match_time_excluded(struct archive *, struct archive_entry *);

int archive_match_include_time(struct archive *, int _flag, intptr_t _sec, long _nsec);
int archive_match_include_date(struct archive *, int _flag, const char *_datestr);
int archive_match_include_date_w(struct archive *, int _flag, const wchar_t *_datestr);
int archive_match_include_file_time(struct archive *, int _flag, const char *_pathname);
int archive_match_include_file_time_w(struct archive *, int _flag, const wchar_t *_pathname);
int archive_match_exclude_entry(struct archive *, int _flag, struct archive_entry *);

int archive_match_owner_excluded(struct archive *, struct archive_entry *);
int archive_match_include_uid(struct archive *, int64_t);
int archive_match_include_gid(struct archive *, int64_t);
int archive_match_include_uname(struct archive *, const char *);
int archive_match_include_uname_w(struct archive *, const wchar_t *);
int archive_match_include_gname(struct archive *, const char *);
int archive_match_include_gname_w(struct archive *, const wchar_t *);
]]
ffi.cdef(header)
function readAll(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end
local header_entry=[[


struct archive;
struct archive_entry;

struct archive_entry    *archive_entry_clear(struct archive_entry *);
struct archive_entry    *archive_entry_clone(struct archive_entry *);
void             archive_entry_free(struct archive_entry *);
struct archive_entry    *archive_entry_new(void);

struct archive_entry    *archive_entry_new2(struct archive *);

la_time_t    archive_entry_atime(struct archive_entry *);
long         archive_entry_atime_nsec(struct archive_entry *);
int      archive_entry_atime_is_set(struct archive_entry *);
la_time_t    archive_entry_birthtime(struct archive_entry *);
long         archive_entry_birthtime_nsec(struct archive_entry *);
int      archive_entry_birthtime_is_set(struct archive_entry *);
la_time_t    archive_entry_ctime(struct archive_entry *);
long         archive_entry_ctime_nsec(struct archive_entry *);
int      archive_entry_ctime_is_set(struct archive_entry *);
la_dev_t         archive_entry_dev(struct archive_entry *);
int      archive_entry_dev_is_set(struct archive_entry *);
la_dev_t         archive_entry_devmajor(struct archive_entry *);
la_dev_t         archive_entry_devminor(struct archive_entry *);
la_mode_t    archive_entry_filetype(struct archive_entry *);
void         archive_entry_fflags(struct archive_entry *, unsigned long * /* set */, unsigned long * /* clear */);
const char  *archive_entry_fflags_text(struct archive_entry *);
int64_t  archive_entry_gid(struct archive_entry *);
const char  *archive_entry_gname(struct archive_entry *);
const wchar_t   *archive_entry_gname_w(struct archive_entry *);
const char  *archive_entry_hardlink(struct archive_entry *);
const wchar_t   *archive_entry_hardlink_w(struct archive_entry *);
int64_t  archive_entry_ino(struct archive_entry *);
int64_t  archive_entry_ino64(struct archive_entry *);
int      archive_entry_ino_is_set(struct archive_entry *);
la_mode_t    archive_entry_mode(struct archive_entry *);
la_time_t    archive_entry_mtime(struct archive_entry *);
long         archive_entry_mtime_nsec(struct archive_entry *);
int      archive_entry_mtime_is_set(struct archive_entry *);
unsigned int     archive_entry_nlink(struct archive_entry *);
const char  *archive_entry_pathname(struct archive_entry *);
const wchar_t   *archive_entry_pathname_w(struct archive_entry *);
la_mode_t    archive_entry_perm(struct archive_entry *);
la_dev_t         archive_entry_rdev(struct archive_entry *);
la_dev_t         archive_entry_rdevmajor(struct archive_entry *);
la_dev_t         archive_entry_rdevminor(struct archive_entry *);
const char  *archive_entry_sourcepath(struct archive_entry *);
const wchar_t   *archive_entry_sourcepath_w(struct archive_entry *);
int64_t  archive_entry_size(struct archive_entry *);
int      archive_entry_size_is_set(struct archive_entry *);
const char  *archive_entry_strmode(struct archive_entry *);
const char  *archive_entry_symlink(struct archive_entry *);
const wchar_t   *archive_entry_symlink_w(struct archive_entry *);
int64_t  archive_entry_uid(struct archive_entry *);
const char  *archive_entry_uname(struct archive_entry *);
const wchar_t   *archive_entry_uname_w(struct archive_entry *);

void    archive_entry_set_atime(struct archive_entry *, la_time_t, long);
void  archive_entry_unset_atime(struct archive_entry *);
void    archive_entry_set_birthtime(struct archive_entry *, la_time_t, long);
void  archive_entry_unset_birthtime(struct archive_entry *);
void    archive_entry_set_ctime(struct archive_entry *, la_time_t, long);
void  archive_entry_unset_ctime(struct archive_entry *);
void    archive_entry_set_dev(struct archive_entry *, la_dev_t);
void    archive_entry_set_devmajor(struct archive_entry *, la_dev_t);
void    archive_entry_set_devminor(struct archive_entry *, la_dev_t);
void    archive_entry_set_filetype(struct archive_entry *, unsigned int);
void    archive_entry_set_fflags(struct archive_entry *, unsigned long /* set */, unsigned long /* clear */);
const char *archive_entry_copy_fflags_text(struct archive_entry *, const char *);
const wchar_t *archive_entry_copy_fflags_text_w(struct archive_entry *, const wchar_t *);
void    archive_entry_set_gid(struct archive_entry *, int64_t);
void    archive_entry_set_gname(struct archive_entry *, const char *);
void    archive_entry_copy_gname(struct archive_entry *, const char *);
void    archive_entry_copy_gname_w(struct archive_entry *, const wchar_t *);
int archive_entry_update_gname_utf8(struct archive_entry *, const char *);
void    archive_entry_set_hardlink(struct archive_entry *, const char *);
void    archive_entry_copy_hardlink(struct archive_entry *, const char *);
void    archive_entry_copy_hardlink_w(struct archive_entry *, const wchar_t *);
int archive_entry_update_hardlink_utf8(struct archive_entry *, const char *);
void    archive_entry_set_ino(struct archive_entry *, int64_t);
void    archive_entry_set_ino64(struct archive_entry *, int64_t);
void    archive_entry_set_link(struct archive_entry *, const char *);
void    archive_entry_copy_link(struct archive_entry *, const char *);
void    archive_entry_copy_link_w(struct archive_entry *, const wchar_t *);
int archive_entry_update_link_utf8(struct archive_entry *, const char *);
void    archive_entry_set_mode(struct archive_entry *, la_mode_t);
void    archive_entry_set_mtime(struct archive_entry *, la_time_t, long);
void  archive_entry_unset_mtime(struct archive_entry *);
void    archive_entry_set_nlink(struct archive_entry *, unsigned int);
void    archive_entry_set_pathname(struct archive_entry *, const char *);
void    archive_entry_copy_pathname(struct archive_entry *, const char *);
void    archive_entry_copy_pathname_w(struct archive_entry *, const wchar_t *);
int archive_entry_update_pathname_utf8(struct archive_entry *, const char *);
void    archive_entry_set_perm(struct archive_entry *, la_mode_t);
void    archive_entry_set_rdev(struct archive_entry *, la_dev_t);
void    archive_entry_set_rdevmajor(struct archive_entry *, la_dev_t);
void    archive_entry_set_rdevminor(struct archive_entry *, la_dev_t);
void    archive_entry_set_size(struct archive_entry *, int64_t);
void    archive_entry_unset_size(struct archive_entry *);
void    archive_entry_copy_sourcepath(struct archive_entry *, const char *);
void    archive_entry_copy_sourcepath_w(struct archive_entry *, const wchar_t *);
void    archive_entry_set_symlink(struct archive_entry *, const char *);
void    archive_entry_copy_symlink(struct archive_entry *, const char *);
void    archive_entry_copy_symlink_w(struct archive_entry *, const wchar_t *);
int archive_entry_update_symlink_utf8(struct archive_entry *, const char *);
void    archive_entry_set_uid(struct archive_entry *, int64_t);
void    archive_entry_set_uname(struct archive_entry *, const char *);
void    archive_entry_copy_uname(struct archive_entry *, const char *);
void    archive_entry_copy_uname_w(struct archive_entry *, const wchar_t *);
int archive_entry_update_uname_utf8(struct archive_entry *, const char *);
const struct stat   *archive_entry_stat(struct archive_entry *);
void    archive_entry_copy_stat(struct archive_entry *, const struct stat *);

const void * archive_entry_mac_metadata(struct archive_entry *, size_t *);
void archive_entry_copy_mac_metadata(struct archive_entry *, const void *, size_t);

void     archive_entry_acl_clear(struct archive_entry *);
int  archive_entry_acl_add_entry(struct archive_entry *, int /* type */, int /* permset */, int /* tag */, int /* qual */, const char * /* name */);
int  archive_entry_acl_add_entry_w(struct archive_entry *, int /* type */, int /* permset */, int /* tag */, int /* qual */, const wchar_t * /* name */);

int  archive_entry_acl_reset(struct archive_entry *, int /* want_type */);
int  archive_entry_acl_next(struct archive_entry *, int /* want_type */, int * /* type */, int * /* permset */, int * /* tag */, int * /* qual */, const char ** /* name */);
int  archive_entry_acl_next_w(struct archive_entry *, int /* want_type */, int * /* type */, int * /* permset */, int * /* tag */, int * /* qual */, const wchar_t ** /* name */);

const wchar_t   *archive_entry_acl_text_w(struct archive_entry *, int /* flags */);
const char *archive_entry_acl_text(struct archive_entry *, int /* flags */);

int  archive_entry_acl_count(struct archive_entry *, int /* want_type */);

struct archive_acl;
struct archive_acl *archive_entry_acl(struct archive_entry *);

void     archive_entry_xattr_clear(struct archive_entry *);
void     archive_entry_xattr_add_entry(struct archive_entry *, const char * /* name */, const void * /* value */, size_t /* size */);

int archive_entry_xattr_count(struct archive_entry *);
int archive_entry_xattr_reset(struct archive_entry *);
int archive_entry_xattr_next(struct archive_entry *, const char ** /* name */, const void ** /* value */, size_t *);

void     archive_entry_sparse_clear(struct archive_entry *);
void     archive_entry_sparse_add_entry(struct archive_entry *, int64_t /* offset */, int64_t /* length */);

int archive_entry_sparse_count(struct archive_entry *);
int archive_entry_sparse_reset(struct archive_entry *);
int archive_entry_sparse_next(struct archive_entry *, int64_t * /* offset */, int64_t * /* length */);

struct archive_entry_linkresolver;

struct archive_entry_linkresolver *archive_entry_linkresolver_new(void);
void archive_entry_linkresolver_set_strategy(
    struct archive_entry_linkresolver *, int /* format_code */);
void archive_entry_linkresolver_free(struct archive_entry_linkresolver *);
void archive_entry_linkify(struct archive_entry_linkresolver *, struct archive_entry **, struct archive_entry **);
struct archive_entry *archive_entry_partial_links(
    struct archive_entry_linkresolver *res, unsigned int *links);

]]
ffi.cdef(header_entry)


-- export constants
M.ARCHIVE_EOF =       1 -- -- /* Found end of archive. */
M.ARCHIVE_OK =    0 -- -- /* Operation was successful. */
M.ARCHIVE_RETRY =   (-10)   -- -- /* Retry might succeed. */
M.ARCHIVE_WARN =    (-20)   -- -- /* Partial success. */
M.ARCHIVE_FAILED =  (-25)   -- -- /* Current operation cannot complete. */
M.ARCHIVE_FATAL =   (-30)   -- -- /* No more operations are possible. */
M.ARCHIVE_FILTER_NONE =     0
M.ARCHIVE_FILTER_GZIP =     1
M.ARCHIVE_FILTER_BZIP2 =    2
M.ARCHIVE_FILTER_COMPRESS =     3
M.ARCHIVE_FILTER_PROGRAM =  4
M.ARCHIVE_FILTER_LZMA =     5
M.ARCHIVE_FILTER_XZ =   6
M.ARCHIVE_FILTER_UU =   7
M.ARCHIVE_FILTER_RPM =  8
M.ARCHIVE_FILTER_LZIP =     9
M.ARCHIVE_FILTER_LRZIP =    10
M.ARCHIVE_FILTER_LZOP =     11
M.ARCHIVE_FILTER_GRZIP =    12
M.ARCHIVE_FORMAT_BASE_MASK =        0xff0000
M.ARCHIVE_FORMAT_CPIO =             0x10000
M.ARCHIVE_FORMAT_CPIO_POSIX =       bit.bor(M.ARCHIVE_FORMAT_CPIO , 1)
M.ARCHIVE_FORMAT_CPIO_BIN_LE =      bit.bor(M.ARCHIVE_FORMAT_CPIO , 2)
M.ARCHIVE_FORMAT_CPIO_BIN_BE =      bit.bor(M.ARCHIVE_FORMAT_CPIO , 3)
M.ARCHIVE_FORMAT_CPIO_SVR4_NOCRC =      bit.bor(M.ARCHIVE_FORMAT_CPIO , 4)
M.ARCHIVE_FORMAT_CPIO_SVR4_CRC =        bit.bor(M.ARCHIVE_FORMAT_CPIO , 5)
M.ARCHIVE_FORMAT_CPIO_AFIO_LARGE =      bit.bor(M.ARCHIVE_FORMAT_CPIO , 6)
M.ARCHIVE_FORMAT_SHAR =             0x20000
M.ARCHIVE_FORMAT_SHAR_BASE =        bit.bor(M.ARCHIVE_FORMAT_SHAR , 1)
M.ARCHIVE_FORMAT_SHAR_DUMP =        bit.bor(M.ARCHIVE_FORMAT_SHAR , 2)
M.ARCHIVE_FORMAT_TAR =          0x30000
M.ARCHIVE_FORMAT_TAR_USTAR =        bit.bor(M.ARCHIVE_FORMAT_TAR , 1)
M.ARCHIVE_FORMAT_TAR_PAX_INTERCHANGE =  bit.bor(M.ARCHIVE_FORMAT_TAR , 2)
M.ARCHIVE_FORMAT_TAR_PAX_RESTRICTED =   bit.bor(M.ARCHIVE_FORMAT_TAR , 3)
M.ARCHIVE_FORMAT_TAR_GNUTAR =       bit.bor(M.ARCHIVE_FORMAT_TAR , 4)
M.ARCHIVE_FORMAT_ISO9660 =          0x40000
M.ARCHIVE_FORMAT_ISO9660_ROCKRIDGE =    bit.bor(M.ARCHIVE_FORMAT_ISO9660 , 1)
M.ARCHIVE_FORMAT_ZIP =          0x50000
M.ARCHIVE_FORMAT_EMPTY =            0x60000
M.ARCHIVE_FORMAT_AR =           0x70000
M.ARCHIVE_FORMAT_AR_GNU =           bit.bor(M.ARCHIVE_FORMAT_AR , 1)
M.ARCHIVE_FORMAT_AR_BSD =           bit.bor(M.ARCHIVE_FORMAT_AR , 2)
M.ARCHIVE_FORMAT_MTREE =            0x80000
M.ARCHIVE_FORMAT_RAW =          0x90000
M.ARCHIVE_FORMAT_XAR =          0xA0000
M.ARCHIVE_FORMAT_LHA =          0xB0000
M.ARCHIVE_FORMAT_CAB =          0xC0000
M.ARCHIVE_FORMAT_RAR =          0xD0000
M.ARCHIVE_FORMAT_7ZIP =             0xE0000
M.ARCHIVE_EXTRACT_OWNER =           (0x0001)
M.ARCHIVE_EXTRACT_PERM =            (0x0002)
M.ARCHIVE_EXTRACT_TIME =            (0x0004)
M.ARCHIVE_EXTRACT_NO_OVERWRITE =        (0x0008)
M.ARCHIVE_EXTRACT_UNLINK =          (0x0010)
M.ARCHIVE_EXTRACT_ACL =             (0x0020)
M.ARCHIVE_EXTRACT_FFLAGS =          (0x0040)
M.ARCHIVE_EXTRACT_XATTR =           (0x0080)
M.ARCHIVE_EXTRACT_SECURE_SYMLINKS =         (0x0100)
M.ARCHIVE_EXTRACT_SECURE_NODOTDOT =         (0x0200)
M.ARCHIVE_EXTRACT_NO_AUTODIR =      (0x0400)
M.ARCHIVE_EXTRACT_NO_OVERWRITE_NEWER =  (0x0800)
M.ARCHIVE_EXTRACT_SPARSE =          (0x1000)
M.ARCHIVE_EXTRACT_MAC_METADATA =        (0x2000)
M.ARCHIVE_EXTRACT_NO_HFS_COMPRESSION =  (0x4000)
M.ARCHIVE_EXTRACT_HFS_COMPRESSION_FORCED =  (0x8000)
M.ARCHIVE_READDISK_RESTORE_ATIME =      (0x0001)
M.ARCHIVE_READDISK_HONOR_NODUMP =       (0x0002)
M.ARCHIVE_READDISK_MAC_COPYFILE =       (0x0004)
M.ARCHIVE_READDISK_NO_TRAVERSE_MOUNTS =     (0x0008)
M.ARCHIVE_MATCH_MTIME =     (0x0100)
M.ARCHIVE_MATCH_CTIME =     (0x0200)
M.ARCHIVE_MATCH_NEWER =     (0x0001)
M.ARCHIVE_MATCH_OLDER =     (0x0002)
M.ARCHIVE_MATCH_EQUAL =     (0x0010)

-- -- -- -- --

M.AE_IFMT =         0170000 -- ((la_mode_t)0170000)
M.AE_IFREG =    0100000 -- ((la_mode_t)0100000)
M.AE_IFLNK =    0120000 -- ((la_mode_t)0120000)
M.AE_IFSOCK =   0140000 -- ((la_mode_t)0140000)
M.AE_IFCHR =    0020000 -- ((la_mode_t)0020000)
M.AE_IFBLK =    0060000 -- ((la_mode_t)0060000)
M.AE_IFDIR =    0040000 -- ((la_mode_t)0040000)
M.AE_IFIFO =    0010000 -- ((la_mode_t)0010000)
M.ARCHIVE_ENTRY_ACL_EXECUTE =              0x00000001
M.ARCHIVE_ENTRY_ACL_WRITE =                0x00000002
M.ARCHIVE_ENTRY_ACL_READ =                 0x00000004
M.ARCHIVE_ENTRY_ACL_READ_DATA =            0x00000008
M.ARCHIVE_ENTRY_ACL_LIST_DIRECTORY =       0x00000008
M.ARCHIVE_ENTRY_ACL_WRITE_DATA =           0x00000010
M.ARCHIVE_ENTRY_ACL_ADD_FILE =             0x00000010
M.ARCHIVE_ENTRY_ACL_APPEND_DATA =          0x00000020
M.ARCHIVE_ENTRY_ACL_ADD_SUBDIRECTORY =     0x00000020
M.ARCHIVE_ENTRY_ACL_READ_NAMED_ATTRS =     0x00000040
M.ARCHIVE_ENTRY_ACL_WRITE_NAMED_ATTRS =    0x00000080
M.ARCHIVE_ENTRY_ACL_DELETE_CHILD =         0x00000100
M.ARCHIVE_ENTRY_ACL_READ_ATTRIBUTES =      0x00000200
M.ARCHIVE_ENTRY_ACL_WRITE_ATTRIBUTES =     0x00000400
M.ARCHIVE_ENTRY_ACL_DELETE =               0x00000800
M.ARCHIVE_ENTRY_ACL_READ_ACL =             0x00001000
M.ARCHIVE_ENTRY_ACL_WRITE_ACL =            0x00002000
M.ARCHIVE_ENTRY_ACL_WRITE_OWNER =          0x00004000
M.ARCHIVE_ENTRY_ACL_SYNCHRONIZE =          0x00008000
M.ARCHIVE_ENTRY_ACL_PERMS_POSIX1E =        bit.bor(M.ARCHIVE_ENTRY_ACL_EXECUTE , M.ARCHIVE_ENTRY_ACL_WRITE , M.ARCHIVE_ENTRY_ACL_READ)
M.ARCHIVE_ENTRY_ACL_PERMS_NFS4 =            bit.bor(M.ARCHIVE_ENTRY_ACL_EXECUTE , M.ARCHIVE_ENTRY_ACL_READ_DATA , M.ARCHIVE_ENTRY_ACL_LIST_DIRECTORY , M.ARCHIVE_ENTRY_ACL_WRITE_DATA , M.ARCHIVE_ENTRY_ACL_ADD_FILE , M.ARCHIVE_ENTRY_ACL_APPEND_DATA , M.ARCHIVE_ENTRY_ACL_ADD_SUBDIRECTORY , M.ARCHIVE_ENTRY_ACL_READ_NAMED_ATTRS , M.ARCHIVE_ENTRY_ACL_WRITE_NAMED_ATTRS , M.ARCHIVE_ENTRY_ACL_DELETE_CHILD , M.ARCHIVE_ENTRY_ACL_READ_ATTRIBUTES , M.ARCHIVE_ENTRY_ACL_WRITE_ATTRIBUTES , M.ARCHIVE_ENTRY_ACL_DELETE , M.ARCHIVE_ENTRY_ACL_READ_ACL , M.ARCHIVE_ENTRY_ACL_WRITE_ACL , M.ARCHIVE_ENTRY_ACL_WRITE_OWNER , M.ARCHIVE_ENTRY_ACL_SYNCHRONIZE)

M.ARCHIVE_ENTRY_ACL_ENTRY_FILE_INHERIT =                 0x02000000
M.ARCHIVE_ENTRY_ACL_ENTRY_DIRECTORY_INHERIT =            0x04000000
M.ARCHIVE_ENTRY_ACL_ENTRY_NO_PROPAGATE_INHERIT =         0x08000000
M.ARCHIVE_ENTRY_ACL_ENTRY_INHERIT_ONLY =                 0x10000000
M.ARCHIVE_ENTRY_ACL_ENTRY_SUCCESSFUL_ACCESS =            0x20000000
M.ARCHIVE_ENTRY_ACL_ENTRY_FAILED_ACCESS =                0x40000000
M.ARCHIVE_ENTRY_ACL_INHERITANCE_NFS4 =  bit.bor(M.ARCHIVE_ENTRY_ACL_ENTRY_FILE_INHERIT , M.ARCHIVE_ENTRY_ACL_ENTRY_DIRECTORY_INHERIT , M.ARCHIVE_ENTRY_ACL_ENTRY_NO_PROPAGATE_INHERIT , M.ARCHIVE_ENTRY_ACL_ENTRY_INHERIT_ONLY , M.ARCHIVE_ENTRY_ACL_ENTRY_SUCCESSFUL_ACCESS , M.ARCHIVE_ENTRY_ACL_ENTRY_FAILED_ACCESS)
M.ARCHIVE_ENTRY_ACL_TYPE_ACCESS =   256  -- /* POSIX.1e only */
M.ARCHIVE_ENTRY_ACL_TYPE_DEFAULT =  512  -- /* POSIX.1e only */
M.ARCHIVE_ENTRY_ACL_TYPE_ALLOW =    1024 -- /* NFS4 only */
M.ARCHIVE_ENTRY_ACL_TYPE_DENY =     2048 -- /* NFS4 only */
M.ARCHIVE_ENTRY_ACL_TYPE_AUDIT =    4096 -- /* NFS4 only */
M.ARCHIVE_ENTRY_ACL_TYPE_ALARM =    8192 -- /* NFS4 only */
M.ARCHIVE_ENTRY_ACL_TYPE_POSIX1E =  bit.bor(M.ARCHIVE_ENTRY_ACL_TYPE_ACCESS , M.ARCHIVE_ENTRY_ACL_TYPE_DEFAULT)
M.ARCHIVE_ENTRY_ACL_TYPE_NFS4 =     bit.bor(M.ARCHIVE_ENTRY_ACL_TYPE_ALLOW , M.ARCHIVE_ENTRY_ACL_TYPE_DENY , M.ARCHIVE_ENTRY_ACL_TYPE_AUDIT , M.ARCHIVE_ENTRY_ACL_TYPE_ALARM)
M.ARCHIVE_ENTRY_ACL_USER =      10001   -- /* Specified user. */
M.ARCHIVE_ENTRY_ACL_USER_OBJ =      10002   -- /* User who owns the file. */
M.ARCHIVE_ENTRY_ACL_GROUP =         10003   -- /* Specified group. */
M.ARCHIVE_ENTRY_ACL_GROUP_OBJ =     10004   -- /* Group who owns the file. */
M.ARCHIVE_ENTRY_ACL_MASK =      10005   -- /* Modify group access (POSIX.1e only) */
M.ARCHIVE_ENTRY_ACL_OTHER =         10006   -- /* Public (POSIX.1e only) */
M.ARCHIVE_ENTRY_ACL_EVERYONE =  10107   -- /* Everyone (NFS4 only) */
M.ARCHIVE_ENTRY_ACL_STYLE_EXTRA_ID =    1024
M.ARCHIVE_ENTRY_ACL_STYLE_MARK_DEFAULT =    2048


-- export ffi functions in module.
M._lib = lib

setmetatable(M, { 
    __index = function (table, key) 
        return rawget(table, key) ~= nil or lib[key] 
    end 
})

--[[
local func
for func in header:gmatch("\n[a-su-z_A-Z][%w%s*_]*(archive_[^%s]+)%(") do
    M[func] = lib[func]
end

for func in header_entry:gmatch("\n[a-s_u-z_A-Z][%w%s*_]*(archive_entry_[^%s]+)%s*%(") do
    if func ~= "archive_entry_acl_next_w" then
        M[func] = lib[func]
    end
end
]]

M.archive_read_new = function()
    return ffi.gc(lib.archive_read_new(), lib.archive_read_free)
end

M.archive_write_new = function()
    return ffi.gc(lib.archive_write_new(), lib.archive_write_free)
end

M.archive_write_disk_new = function()
    return ffi.gc(lib.archive_write_disk_new(), lib.archive_write_disk_free)
end

M.archive_read_disk_new = function()
    return ffi.gc(lib.archive_read_disk_new(), lib.archive_read_disk_free)
end

M.archive_match_new = function()
    return ffi.gc(lib.archive_match_new(), lib.archive_match_free)
end

M.archive_entry_new = function()
    return ffi.gc(lib.archive_entry_new(), lib.archive_entry_free)
end

M.archive_entry_new2 = function()
    return ffi.gc(lib.archive_entry_new2(), lib.archive_entry_free)
end

M.archive_entry_linkresolver_new = function()
    return ffi.gc(lib.archive_entry_linkresolver_new(), lib.archive_entry_linkresolver_free)
end

return M;
