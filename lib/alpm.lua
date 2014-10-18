local ffi = require("ffi")
local lib = ffi.load("alpm")
local bit = require("bit")

function readAll(file)
    local f = io.open(file, "rb")
    local content = f:read("*all")
    f:close()
    return content
end


local M = {}
setmetatable(M, {__index = lib})
ffi.cdef[[
typedef long int alpm_off_t;
typedef unsigned int alpm_mode_t;
]]


--ffi.cdef(readAll("alpm_list.h"))
ffi.cdef[[
/*
 *  alpm_list.h
 *
 *  Copyright (c) 2006-2013 Pacman Development Team <pacman-dev@archlinux.org>
 *  Copyright (c) 2002-2006 by Judd Vinet <jvinet@zeroflux.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @brief Linked list type used by libalpm.
 *
 * It is exposed so front ends can use it to prevent the need to reimplement
 * lists of their own; however, it is not required that the front end uses
 * it.
 */
typedef struct __alpm_list_t {
	/** data held by the list node */
	void *data;
	/** pointer to the previous node */
	struct __alpm_list_t *prev;
	/** pointer to the next node */
	struct __alpm_list_t *next;
} alpm_list_t;


typedef void (*alpm_list_fn_free)(void *); /* item deallocation callback */
typedef int (*alpm_list_fn_cmp)(const void *, const void *); /* item comparison callback */

/* allocation */
void alpm_list_free(alpm_list_t *list);
void alpm_list_free_inner(alpm_list_t *list, alpm_list_fn_free fn);

/* item mutators */
alpm_list_t *alpm_list_add(alpm_list_t *list, void *data);
alpm_list_t *alpm_list_add_sorted(alpm_list_t *list, void *data, alpm_list_fn_cmp fn);
alpm_list_t *alpm_list_join(alpm_list_t *first, alpm_list_t *second);
alpm_list_t *alpm_list_mmerge(alpm_list_t *left, alpm_list_t *right, alpm_list_fn_cmp fn);
alpm_list_t *alpm_list_msort(alpm_list_t *list, size_t n, alpm_list_fn_cmp fn);
alpm_list_t *alpm_list_remove_item(alpm_list_t *haystack, alpm_list_t *item);
alpm_list_t *alpm_list_remove(alpm_list_t *haystack, const void *needle, alpm_list_fn_cmp fn, void **data);
alpm_list_t *alpm_list_remove_str(alpm_list_t *haystack, const char *needle, char **data);
alpm_list_t *alpm_list_remove_dupes(const alpm_list_t *list);
alpm_list_t *alpm_list_strdup(const alpm_list_t *list);
alpm_list_t *alpm_list_copy(const alpm_list_t *list);
alpm_list_t *alpm_list_copy_data(const alpm_list_t *list, size_t size);
alpm_list_t *alpm_list_reverse(alpm_list_t *list);

/* item accessors */
alpm_list_t *alpm_list_nth(const alpm_list_t *list, size_t n);
alpm_list_t *alpm_list_next(const alpm_list_t *list);
alpm_list_t *alpm_list_previous(const alpm_list_t *list);
alpm_list_t *alpm_list_last(const alpm_list_t *list);

/* misc */
size_t alpm_list_count(const alpm_list_t *list);
void *alpm_list_find(const alpm_list_t *haystack, const void *needle, alpm_list_fn_cmp fn);
void *alpm_list_find_ptr(const alpm_list_t *haystack, const void *needle);
char *alpm_list_find_str(const alpm_list_t *haystack, const char *needle);
alpm_list_t *alpm_list_diff(const alpm_list_t *lhs, const alpm_list_t *rhs, alpm_list_fn_cmp fn);
void alpm_list_diff_sorted(const alpm_list_t *left, const alpm_list_t *right,
		alpm_list_fn_cmp fn, alpm_list_t **onlyleft, alpm_list_t **onlyright);
void *alpm_list_to_array(const alpm_list_t *list, size_t n, size_t size);

/* vim: set ts=2 sw=2 noet: */
]]
local List_mt = { __index = {
    free = lib.alpm_list_free,
    free_inner = lib.alpm_list_free_inner,
	add = function(self, data)
		return lib.alpm_list_add(self, data)
	end,
	add_sorted = function(self, data, cmpfn)
		return lib.alpm_list_add_sorted(self, data, cmpfn)
	end,
	join = function(self, list)
		return lib.alpm_list_join(self, list)
	end,
	mmerge = function(self, list, cmpfn)
		return lib.alpm_list_mmerge(self, list, cmpfn)
	end,
	msort = function(self, list, cmpfn)
		return lib.alpm_list_add(self, list, cmpfn)
	end,
	remove = lib.alpm_list_remove,
	remove_str = lib.alpm_list_remove_str,
	remove_dupes = lib.alpm_list_remove_dupes,
	strdup = lib.alpm_list_strdup,
	copy = lib.alpm_list_copy,
	copy_data = lib.alpm_list_copy_data,
	reverse = lib.alpm_list_reverse,
	nth = lib.alpm_list_nth,
	prev = lib.alpm_list_previous,
	previous = lib.alpm_list_previous,
	last = lib.alpm_list_last,
	count = lib.alpm_list_count,
	find = function(self, needle, cmpfn)
		if cmpfn then
			return lib.alpm_list_find(self, needle, cmpfn)
		elseif typeof(needle) == 'cdata' then
			return lib.alpm_list_find_ptr(self, needle)
		else
			return lib.alpm_list_find_str(self, needle)
		end
	end,
	diff = lib.alpm_list_diff,
	diff_sorted = lib.alpm_list_diff_sorted,
	to_array = lib.alpm_list_to_array,
	to_table = function(self, convertfn)
		convertfn = convertfn or function(v) return v end
		local n=self
		local t={}
		while n ~= nil do
			t[#t+1] = convertfn(n.data)
			n = n:forwards()
		end
		return t
	end,
	forwards = lib.alpm_list_next,
	_next = lib.alpm_list_next,
	next_ = lib.alpm_list_next,
	Next = lib.alpm_list_next,
    ['next'] = lib.alpm_list_next,
	iter = function(self, convfn)
		return function(a, i)
			local n=a[1]
			i = i + 1
			if n ~= nil then
				a[1] = n:forwards()
				if convfn then return i , convfn(n.data) end
				return i , n.data
			end
		end, {self}, 0
	end
}}
M.List = ffi.metatype("alpm_list_t", List_mt)
--ffi.cdef(readAll("alpm.h"))
ffi.cdef[[
/*
 * alpm.h
 *
 *  Copyright (c) 2006-2013 Pacman Development Team <pacman-dev@archlinux.org>
 *  Copyright (c) 2002-2006 by Judd Vinet <jvinet@zeroflux.org>
 *  Copyright (c) 2005 by Aurelien Foret <orelien@chez.com>
 *  Copyright (c) 2005 by Christian Hamar <krics@linuxforum.hu>
 *  Copyright (c) 2005, 2006 by Miklos Vajna <vmiklos@frugalware.org>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/* libarchive */

/*
 * Arch Linux Package Management library
 */

/** @addtogroup alpm_api Public API
 * The libalpm Public API
 * @{
 */

typedef int64_t alpm_time_t;

/*
 * Enumerations
 * These ones are used in multiple contexts, so are forward-declared.
 */

/** Package install reasons. */
typedef enum _alpm_pkgreason_t {
	/** Explicitly requested by the user. */
	ALPM_PKG_REASON_EXPLICIT = 0,
	/** Installed as a dependency for another package. */
	ALPM_PKG_REASON_DEPEND = 1
} alpm_pkgreason_t;

/** Location a package object was loaded from. */
typedef enum _alpm_pkgfrom_t {
	ALPM_PKG_FROM_FILE = 1,
	ALPM_PKG_FROM_LOCALDB,
	ALPM_PKG_FROM_SYNCDB
} alpm_pkgfrom_t;

/** Method used to validate a package. */
typedef enum _alpm_pkgvalidation_t {
	ALPM_PKG_VALIDATION_UNKNOWN = 0,
	ALPM_PKG_VALIDATION_NONE = (1 << 0),
	ALPM_PKG_VALIDATION_MD5SUM = (1 << 1),
	ALPM_PKG_VALIDATION_SHA256SUM = (1 << 2),
	ALPM_PKG_VALIDATION_SIGNATURE = (1 << 3)
} alpm_pkgvalidation_t;

/** Types of version constraints in dependency specs. */
typedef enum _alpm_depmod_t {
  /** No version constraint */
	ALPM_DEP_MOD_ANY = 1,
  /** Test version equality (package=x.y.z) */
	ALPM_DEP_MOD_EQ,
  /** Test for at least a version (package>=x.y.z) */
	ALPM_DEP_MOD_GE,
  /** Test for at most a version (package<=x.y.z) */
	ALPM_DEP_MOD_LE,
  /** Test for greater than some version (package>x.y.z) */
	ALPM_DEP_MOD_GT,
  /** Test for less than some version (package<x.y.z) */
	ALPM_DEP_MOD_LT
} alpm_depmod_t;

/**
 * File conflict type.
 * Whether the conflict results from a file existing on the filesystem, or with
 * another target in the transaction.
 */
typedef enum _alpm_fileconflicttype_t {
	ALPM_FILECONFLICT_TARGET = 1,
	ALPM_FILECONFLICT_FILESYSTEM
} alpm_fileconflicttype_t;

/** PGP signature verification options */
typedef enum _alpm_siglevel_t {
	ALPM_SIG_PACKAGE = (1 << 0),
	ALPM_SIG_PACKAGE_OPTIONAL = (1 << 1),
	ALPM_SIG_PACKAGE_MARGINAL_OK = (1 << 2),
	ALPM_SIG_PACKAGE_UNKNOWN_OK = (1 << 3),

	ALPM_SIG_DATABASE = (1 << 10),
	ALPM_SIG_DATABASE_OPTIONAL = (1 << 11),
	ALPM_SIG_DATABASE_MARGINAL_OK = (1 << 12),
	ALPM_SIG_DATABASE_UNKNOWN_OK = (1 << 13),

	ALPM_SIG_PACKAGE_SET = (1 << 27),
	ALPM_SIG_PACKAGE_TRUST_SET = (1 << 28),

	ALPM_SIG_USE_DEFAULT = (1 << 31)
} alpm_siglevel_t;

/** PGP signature verification status return codes */
typedef enum _alpm_sigstatus_t {
	ALPM_SIGSTATUS_VALID,
	ALPM_SIGSTATUS_KEY_EXPIRED,
	ALPM_SIGSTATUS_SIG_EXPIRED,
	ALPM_SIGSTATUS_KEY_UNKNOWN,
	ALPM_SIGSTATUS_KEY_DISABLED,
	ALPM_SIGSTATUS_INVALID
} alpm_sigstatus_t;

/** PGP signature verification status return codes */
typedef enum _alpm_sigvalidity_t {
	ALPM_SIGVALIDITY_FULL,
	ALPM_SIGVALIDITY_MARGINAL,
	ALPM_SIGVALIDITY_NEVER,
	ALPM_SIGVALIDITY_UNKNOWN
} alpm_sigvalidity_t;

/*
 * Structures
 */

typedef struct __alpm_handle_t alpm_handle_t;
typedef struct __alpm_db_t alpm_db_t;
typedef struct __alpm_pkg_t alpm_pkg_t;
typedef struct __alpm_trans_t alpm_trans_t;

/** Dependency */
typedef struct _alpm_depend_t {
	char *name;
	char *version;
	char *desc;
	unsigned long name_hash;
	alpm_depmod_t mod;
} alpm_depend_t;

/** Missing dependency */
typedef struct _alpm_depmissing_t {
	char *target;
	alpm_depend_t *depend;
	/* this is used only in the case of a remove dependency error */
	char *causingpkg;
} alpm_depmissing_t;

/** Conflict */
typedef struct _alpm_conflict_t {
	unsigned long package1_hash;
	unsigned long package2_hash;
	char *package1;
	char *package2;
	alpm_depend_t *reason;
} alpm_conflict_t;

/** File conflict */
typedef struct _alpm_fileconflict_t {
	char *target;
	alpm_fileconflicttype_t type;
	char *file;
	char *ctarget;
} alpm_fileconflict_t;

/** Package group */
typedef struct _alpm_group_t {
	/** group name */
	char *name;
	/** list of alpm_pkg_t packages */
	alpm_list_t *packages;
} alpm_group_t;

/** Package upgrade delta */
typedef struct _alpm_delta_t {
	/** filename of the delta patch */
	char *delta;
	/** md5sum of the delta file */
	char *delta_md5;
	/** filename of the 'before' file */
	char *from;
	/** filename of the 'after' file */
	char *to;
	/** filesize of the delta file */
	alpm_off_t delta_size;
	/** download filesize of the delta file */
	alpm_off_t download_size;
} alpm_delta_t;

/** File in a package */
typedef struct _alpm_file_t {
	char *name;
	alpm_off_t size;
	alpm_mode_t mode;
} alpm_file_t;

/** Package filelist container */
typedef struct _alpm_filelist_t {
	size_t count;
	alpm_file_t *files;
	char **resolved_path;
} alpm_filelist_t;

/** Local package or package file backup entry */
typedef struct _alpm_backup_t {
	char *name;
	char *hash;
} alpm_backup_t;

typedef struct _alpm_pgpkey_t {
	void *data;
	char *fingerprint;
	char *uid;
	char *name;
	char *email;
	alpm_time_t created;
	alpm_time_t expires;
	unsigned int length;
	unsigned int revoked;
	char pubkey_algo;
} alpm_pgpkey_t;

/**
 * Signature result. Contains the key, status, and validity of a given
 * signature.
 */
typedef struct _alpm_sigresult_t {
	alpm_pgpkey_t key;
	alpm_sigstatus_t status;
	alpm_sigvalidity_t validity;
} alpm_sigresult_t;

/**
 * Signature list. Contains the number of signatures found and a pointer to an
 * array of results.  The array is of size count.
 */
typedef struct _alpm_siglist_t {
	size_t count;
	alpm_sigresult_t *results;
} alpm_siglist_t;

/*
 * Logging facilities
 */

/** Logging Levels */
typedef enum _alpm_loglevel_t {
	ALPM_LOG_ERROR    = 1,
	ALPM_LOG_WARNING  = (1 << 1),
	ALPM_LOG_DEBUG    = (1 << 2),
	ALPM_LOG_FUNCTION = (1 << 3)
} alpm_loglevel_t;

typedef void (*alpm_cb_log)(alpm_loglevel_t, const char *, va_list);

int alpm_logaction(alpm_handle_t *handle, const char *prefix,
		const char *fmt, ...) __attribute__((format(printf, 3, 4)));

/**
 * Events.
 * NULL parameters are passed to in all events unless specified otherwise.
 */
typedef enum _alpm_event_t {
	/** Dependencies will be computed for a package. */
	ALPM_EVENT_CHECKDEPS_START = 1,
	/** Dependencies were computed for a package. */
	ALPM_EVENT_CHECKDEPS_DONE,
	/** File conflicts will be computed for a package. */
	ALPM_EVENT_FILECONFLICTS_START,
	/** File conflicts were computed for a package. */
	ALPM_EVENT_FILECONFLICTS_DONE,
	/** Dependencies will be resolved for target package. */
	ALPM_EVENT_RESOLVEDEPS_START,
	/** Dependencies were resolved for target package. */
	ALPM_EVENT_RESOLVEDEPS_DONE,
	/** Inter-conflicts will be checked for target package. */
	ALPM_EVENT_INTERCONFLICTS_START,
	/** Inter-conflicts were checked for target package. */
	ALPM_EVENT_INTERCONFLICTS_DONE,
	/** Package will be installed.
	 * A pointer to the target package is passed to the callback.
	 */
	ALPM_EVENT_ADD_START,
	/** Package was installed.
	 * A pointer to the new package is passed to the callback.
	 */
	ALPM_EVENT_ADD_DONE,
	/** Package will be removed.
	 * A pointer to the target package is passed to the callback.
	 */
	ALPM_EVENT_REMOVE_START,
	/** Package was removed.
	 * A pointer to the removed package is passed to the callback.
	 */
	ALPM_EVENT_REMOVE_DONE,
	/** Package will be upgraded.
	 * A pointer to the upgraded package is passed to the callback.
	 */
	ALPM_EVENT_UPGRADE_START,
	/** Package was upgraded.
	 * A pointer to the new package, and a pointer to the old package is passed
	 * to the callback, respectively.
	 */
	ALPM_EVENT_UPGRADE_DONE,
	/** Package will be downgraded.
	 * A pointer to the downgraded package is passed to the callback.
	 */
	ALPM_EVENT_DOWNGRADE_START,
	/** Package was downgraded.
	 * A pointer to the new package, and a pointer to the old package is passed
	 * to the callback, respectively.
	 */
	ALPM_EVENT_DOWNGRADE_DONE,
	/** Package will be reinstalled.
	 * A pointer to the reinstalled package is passed to the callback.
	 */
	ALPM_EVENT_REINSTALL_START,
	/** Package was reinstalled.
	 * A pointer to the new package, and a pointer to the old package is passed
	 * to the callback, respectively.
	 */
	ALPM_EVENT_REINSTALL_DONE,
	/** Target package's integrity will be checked. */
	ALPM_EVENT_INTEGRITY_START,
	/** Target package's integrity was checked. */
	ALPM_EVENT_INTEGRITY_DONE,
	/** Target package will be loaded. */
	ALPM_EVENT_LOAD_START,
	/** Target package is finished loading. */
	ALPM_EVENT_LOAD_DONE,
	/** Target delta's integrity will be checked. */
	ALPM_EVENT_DELTA_INTEGRITY_START,
	/** Target delta's integrity was checked. */
	ALPM_EVENT_DELTA_INTEGRITY_DONE,
	/** Deltas will be applied to packages. */
	ALPM_EVENT_DELTA_PATCHES_START,
	/** Deltas were applied to packages. */
	ALPM_EVENT_DELTA_PATCHES_DONE,
	/** Delta patch will be applied to target package.
	 * The filename of the package and the filename of the patch is passed to the
	 * callback.
	 */
	ALPM_EVENT_DELTA_PATCH_START,
	/** Delta patch was applied to target package. */
	ALPM_EVENT_DELTA_PATCH_DONE,
	/** Delta patch failed to apply to target package. */
	ALPM_EVENT_DELTA_PATCH_FAILED,
	/** Scriptlet has printed information.
	 * A line of text is passed to the callback.
	 */
	ALPM_EVENT_SCRIPTLET_INFO,
	/** Files will be downloaded from a repository.
	 * The repository's tree name is passed to the callback.
	 */
	ALPM_EVENT_RETRIEVE_START,
	/** Disk space usage will be computed for a package */
	ALPM_EVENT_DISKSPACE_START,
	/** Disk space usage was computed for a package */
	ALPM_EVENT_DISKSPACE_DONE,
	/** An optdepend for another package is being removed
	 * The requiring package and its dependency are passed to the callback */
	ALPM_EVENT_OPTDEP_REQUIRED,
	/** A configured repository database is missing */
	ALPM_EVENT_DATABASE_MISSING,
	/** Checking keys used to create signatures are in keyring. */
	ALPM_EVENT_KEYRING_START,
	/** Keyring checking is finished. */
	ALPM_EVENT_KEYRING_DONE,
	/** Downloading missing keys into keyring. */
	ALPM_EVENT_KEY_DOWNLOAD_START,
	/** Key downloading is finished. */
	ALPM_EVENT_KEY_DOWNLOAD_DONE
} alpm_event_t;

/** Event callback */
typedef void (*alpm_cb_event)(alpm_event_t, void *, void *);

/**
 * Questions.
 * Unlike the events or progress enumerations, this enum has bitmask values
 * so a frontend can use a bitmask map to supply preselected answers to the
 * different types of questions.
 */
typedef enum _alpm_question_t {
	ALPM_QUESTION_INSTALL_IGNOREPKG = 1,
	ALPM_QUESTION_REPLACE_PKG = (1 << 1),
	ALPM_QUESTION_CONFLICT_PKG = (1 << 2),
	ALPM_QUESTION_CORRUPTED_PKG = (1 << 3),
	ALPM_QUESTION_LOCAL_NEWER = (1 << 4),
	ALPM_QUESTION_REMOVE_PKGS = (1 << 5),
	ALPM_QUESTION_SELECT_PROVIDER = (1 << 6),
	ALPM_QUESTION_IMPORT_KEY = (1 << 7)
} alpm_question_t;

/** Question callback */
typedef void (*alpm_cb_question)(alpm_question_t, void *, void *, void *, int *);

/** Progress */
typedef enum _alpm_progress_t {
	ALPM_PROGRESS_ADD_START,
	ALPM_PROGRESS_UPGRADE_START,
	ALPM_PROGRESS_DOWNGRADE_START,
	ALPM_PROGRESS_REINSTALL_START,
	ALPM_PROGRESS_REMOVE_START,
	ALPM_PROGRESS_CONFLICTS_START,
	ALPM_PROGRESS_DISKSPACE_START,
	ALPM_PROGRESS_INTEGRITY_START,
	ALPM_PROGRESS_LOAD_START,
	ALPM_PROGRESS_KEYRING_START
} alpm_progress_t;

/** Progress callback */
typedef void (*alpm_cb_progress)(alpm_progress_t, const char *, int, size_t, size_t);

/*
 * Downloading
 */

/** Type of download progress callbacks.
 * @param filename the name of the file being downloaded
 * @param xfered the number of transferred bytes
 * @param total the total number of bytes to transfer
 */
typedef void (*alpm_cb_download)(const char *filename,
		alpm_off_t xfered, alpm_off_t total);

typedef void (*alpm_cb_totaldl)(alpm_off_t total);

/** A callback for downloading files
 * @param url the URL of the file to be downloaded
 * @param localpath the directory to which the file should be downloaded
 * @param force whether to force an update, even if the file is the same
 * @return 0 on success, 1 if the file exists and is identical, -1 on
 * error.
 */
typedef int (*alpm_cb_fetch)(const char *url, const char *localpath,
		int force);

/** Fetch a remote pkg.
 * @param handle the context handle
 * @param url URL of the package to download
 * @return the downloaded filepath on success, NULL on error
 */
char *alpm_fetch_pkgurl(alpm_handle_t *handle, const char *url);

/** @addtogroup alpm_api_options Options
 * Libalpm option getters and setters
 * @{
 */

/** Returns the callback used for logging. */
alpm_cb_log alpm_option_get_logcb(alpm_handle_t *handle);
/** Sets the callback used for logging. */
int alpm_option_set_logcb(alpm_handle_t *handle, alpm_cb_log cb);

/** Returns the callback used to report download progress. */
alpm_cb_download alpm_option_get_dlcb(alpm_handle_t *handle);
/** Sets the callback used to report download progress. */
int alpm_option_set_dlcb(alpm_handle_t *handle, alpm_cb_download cb);

/** Returns the downloading callback. */
alpm_cb_fetch alpm_option_get_fetchcb(alpm_handle_t *handle);
/** Sets the downloading callback. */
int alpm_option_set_fetchcb(alpm_handle_t *handle, alpm_cb_fetch cb);

/** Returns the callback used to report total download size. */
alpm_cb_totaldl alpm_option_get_totaldlcb(alpm_handle_t *handle);
/** Sets the callback used to report total download size. */
int alpm_option_set_totaldlcb(alpm_handle_t *handle, alpm_cb_totaldl cb);

/** Returns the callback used for events. */
alpm_cb_event alpm_option_get_eventcb(alpm_handle_t *handle);
/** Sets the callback used for events. */
int alpm_option_set_eventcb(alpm_handle_t *handle, alpm_cb_event cb);

/** Returns the callback used for questions. */
alpm_cb_question alpm_option_get_questioncb(alpm_handle_t *handle);
/** Sets the callback used for questions. */
int alpm_option_set_questioncb(alpm_handle_t *handle, alpm_cb_question cb);

/** Returns the callback used for operation progress. */
alpm_cb_progress alpm_option_get_progresscb(alpm_handle_t *handle);
/** Sets the callback used for operation progress. */
int alpm_option_set_progresscb(alpm_handle_t *handle, alpm_cb_progress cb);

/** Returns the root of the destination filesystem. Read-only. */
const char *alpm_option_get_root(alpm_handle_t *handle);

/** Returns the path to the database directory. Read-only. */
const char *alpm_option_get_dbpath(alpm_handle_t *handle);

/** Get the name of the database lock file. Read-only. */
const char *alpm_option_get_lockfile(alpm_handle_t *handle);

/** @name Accessors to the list of package cache directories.
 * @{
 */
alpm_list_t *alpm_option_get_cachedirs(alpm_handle_t *handle);
int alpm_option_set_cachedirs(alpm_handle_t *handle, alpm_list_t *cachedirs);
int alpm_option_add_cachedir(alpm_handle_t *handle, const char *cachedir);
int alpm_option_remove_cachedir(alpm_handle_t *handle, const char *cachedir);
/** @} */

/** Returns the logfile name. */
const char *alpm_option_get_logfile(alpm_handle_t *handle);
/** Sets the logfile name. */
int alpm_option_set_logfile(alpm_handle_t *handle, const char *logfile);

/** Returns the path to libalpm's GnuPG home directory. */
const char *alpm_option_get_gpgdir(alpm_handle_t *handle);
/** Sets the path to libalpm's GnuPG home directory. */
int alpm_option_set_gpgdir(alpm_handle_t *handle, const char *gpgdir);

/** Returns whether to use syslog (0 is FALSE, TRUE otherwise). */
int alpm_option_get_usesyslog(alpm_handle_t *handle);
/** Sets whether to use syslog (0 is FALSE, TRUE otherwise). */
int alpm_option_set_usesyslog(alpm_handle_t *handle, int usesyslog);

/** @name Accessors to the list of no-upgrade files.
 * These functions modify the list of files which should
 * not be updated by package installation.
 * @{
 */
alpm_list_t *alpm_option_get_noupgrades(alpm_handle_t *handle);
int alpm_option_add_noupgrade(alpm_handle_t *handle, const char *pkg);
int alpm_option_set_noupgrades(alpm_handle_t *handle, alpm_list_t *noupgrade);
int alpm_option_remove_noupgrade(alpm_handle_t *handle, const char *pkg);
/** @} */

/** @name Accessors to the list of no-extract files.
 * These functions modify the list of filenames which should
 * be skipped packages which should
 * not be upgraded by a sysupgrade operation.
 * @{
 */
alpm_list_t *alpm_option_get_noextracts(alpm_handle_t *handle);
int alpm_option_add_noextract(alpm_handle_t *handle, const char *pkg);
int alpm_option_set_noextracts(alpm_handle_t *handle, alpm_list_t *noextract);
int alpm_option_remove_noextract(alpm_handle_t *handle, const char *pkg);
/** @} */

/** @name Accessors to the list of ignored packages.
 * These functions modify the list of packages that
 * should be ignored by a sysupgrade.
 * @{
 */
alpm_list_t *alpm_option_get_ignorepkgs(alpm_handle_t *handle);
int alpm_option_add_ignorepkg(alpm_handle_t *handle, const char *pkg);
int alpm_option_set_ignorepkgs(alpm_handle_t *handle, alpm_list_t *ignorepkgs);
int alpm_option_remove_ignorepkg(alpm_handle_t *handle, const char *pkg);
/** @} */

/** @name Accessors to the list of ignored groups.
 * These functions modify the list of groups whose packages
 * should be ignored by a sysupgrade.
 * @{
 */
alpm_list_t *alpm_option_get_ignoregroups(alpm_handle_t *handle);
int alpm_option_add_ignoregroup(alpm_handle_t *handle, const char *grp);
int alpm_option_set_ignoregroups(alpm_handle_t *handle, alpm_list_t *ignoregrps);
int alpm_option_remove_ignoregroup(alpm_handle_t *handle, const char *grp);
/** @} */

/** Returns the targeted architecture. */
const char *alpm_option_get_arch(alpm_handle_t *handle);
/** Sets the targeted architecture. */
int alpm_option_set_arch(alpm_handle_t *handle, const char *arch);

double alpm_option_get_deltaratio(alpm_handle_t *handle);
int alpm_option_set_deltaratio(alpm_handle_t *handle, double ratio);

int alpm_option_get_checkspace(alpm_handle_t *handle);
int alpm_option_set_checkspace(alpm_handle_t *handle, int checkspace);

alpm_siglevel_t alpm_option_get_default_siglevel(alpm_handle_t *handle);
int alpm_option_set_default_siglevel(alpm_handle_t *handle, alpm_siglevel_t level);

alpm_siglevel_t alpm_option_get_local_file_siglevel(alpm_handle_t *handle);
int alpm_option_set_local_file_siglevel(alpm_handle_t *handle, alpm_siglevel_t level);

alpm_siglevel_t alpm_option_get_remote_file_siglevel(alpm_handle_t *handle);
int alpm_option_set_remote_file_siglevel(alpm_handle_t *handle, alpm_siglevel_t level);

/** @} */

/** @addtogroup alpm_api_databases Database Functions
 * Functions to query and manipulate the database of libalpm.
 * @{
 */

/** Get the database of locally installed packages.
 * The returned pointer points to an internal structure
 * of libalpm which should only be manipulated through
 * libalpm functions.
 * @return a reference to the local database
 */
alpm_db_t *alpm_get_localdb(alpm_handle_t *handle);

/** Get the list of sync databases.
 * Returns a list of alpm_db_t structures, one for each registered
 * sync database.
 * @param handle the context handle
 * @return a reference to an internal list of alpm_db_t structures
 */
alpm_list_t *alpm_get_syncdbs(alpm_handle_t *handle);

/** Register a sync database of packages.
 * @param handle the context handle
 * @param treename the name of the sync repository
 * @param level what level of signature checking to perform on the
 * database; note that this must be a '.sig' file type verification
 * @return an alpm_db_t* on success (the value), NULL on error
 */
alpm_db_t *alpm_register_syncdb(alpm_handle_t *handle, const char *treename,
		alpm_siglevel_t level);

/** Unregister all package databases.
 * @param handle the context handle
 * @return 0 on success, -1 on error (pm_errno is set accordingly)
 */
int alpm_unregister_all_syncdbs(alpm_handle_t *handle);

/** Unregister a package database.
 * @param db pointer to the package database to unregister
 * @return 0 on success, -1 on error (pm_errno is set accordingly)
 */
int alpm_db_unregister(alpm_db_t *db);

/** Get the name of a package database.
 * @param db pointer to the package database
 * @return the name of the package database, NULL on error
 */
const char *alpm_db_get_name(const alpm_db_t *db);

/** Get the signature verification level for a database.
 * Will return the default verification level if this database is set up
 * with ALPM_SIG_USE_DEFAULT.
 * @param db pointer to the package database
 * @return the signature verification level
 */
alpm_siglevel_t alpm_db_get_siglevel(alpm_db_t *db);

/** Check the validity of a database.
 * This is most useful for sync databases and verifying signature status.
 * If invalid, the handle error code will be set accordingly.
 * @param db pointer to the package database
 * @return 0 if valid, -1 if invalid (pm_errno is set accordingly)
 */
int alpm_db_get_valid(alpm_db_t *db);

/** @name Accessors to the list of servers for a database.
 * @{
 */
alpm_list_t *alpm_db_get_servers(const alpm_db_t *db);
int alpm_db_set_servers(alpm_db_t *db, alpm_list_t *servers);
int alpm_db_add_server(alpm_db_t *db, const char *url);
int alpm_db_remove_server(alpm_db_t *db, const char *url);
/** @} */

int alpm_db_update(int force, alpm_db_t *db);

/** Get a package entry from a package database.
 * @param db pointer to the package database to get the package from
 * @param name of the package
 * @return the package entry on success, NULL on error
 */
alpm_pkg_t *alpm_db_get_pkg(alpm_db_t *db, const char *name);

/** Get the package cache of a package database.
 * @param db pointer to the package database to get the package from
 * @return the list of packages on success, NULL on error
 */
alpm_list_t *alpm_db_get_pkgcache(alpm_db_t *db);

/** Get a group entry from a package database.
 * @param db pointer to the package database to get the group from
 * @param name of the group
 * @return the groups entry on success, NULL on error
 */
alpm_group_t *alpm_db_get_group(alpm_db_t *db, const char *name);

/** Get the group cache of a package database.
 * @param db pointer to the package database to get the group from
 * @return the list of groups on success, NULL on error
 */
alpm_list_t *alpm_db_get_groupcache(alpm_db_t *db);

/** Searches a database with regular expressions.
 * @param db pointer to the package database to search in
 * @param needles a list of regular expressions to search for
 * @return the list of packages matching all regular expressions on success, NULL on error
 */
alpm_list_t *alpm_db_search(alpm_db_t *db, const alpm_list_t *needles);

/** @} */

/** @addtogroup alpm_api_packages Package Functions
 * Functions to manipulate libalpm packages
 * @{
 */

/** Create a package from a file.
 * If full is false, the archive is read only until all necessary
 * metadata is found. If it is true, the entire archive is read, which
 * serves as a verification of integrity and the filelist can be created.
 * The allocated structure should be freed using alpm_pkg_free().
 * @param handle the context handle
 * @param filename location of the package tarball
 * @param full whether to stop the load after metadata is read or continue
 * through the full archive
 * @param level what level of package signature checking to perform on the
 * package; note that this must be a '.sig' file type verification
 * @param pkg address of the package pointer
 * @return 0 on success, -1 on error (pm_errno is set accordingly)
 */
int alpm_pkg_load(alpm_handle_t *handle, const char *filename, int full,
		alpm_siglevel_t level, alpm_pkg_t **pkg);

/** Find a package in a list by name.
 * @param haystack a list of alpm_pkg_t
 * @param needle the package name
 * @return a pointer to the package if found or NULL
 */
alpm_pkg_t *alpm_pkg_find(alpm_list_t *haystack, const char *needle);

/** Free a package.
 * @param pkg package pointer to free
 * @return 0 on success, -1 on error (pm_errno is set accordingly)
 */
int alpm_pkg_free(alpm_pkg_t *pkg);

/** Check the integrity (with md5) of a package from the sync cache.
 * @param pkg package pointer
 * @return 0 on success, -1 on error (pm_errno is set accordingly)
 */
int alpm_pkg_checkmd5sum(alpm_pkg_t *pkg);

/** Compare two version strings and determine which one is 'newer'. */
int alpm_pkg_vercmp(const char *a, const char *b);

/** Computes the list of packages requiring a given package.
 * The return value of this function is a newly allocated
 * list of package names (char*), it should be freed by the caller.
 * @param pkg a package
 * @return the list of packages requiring pkg
 */
alpm_list_t *alpm_pkg_compute_requiredby(alpm_pkg_t *pkg);

/** Computes the list of packages optionally requiring a given package.
 * The return value of this function is a newly allocated
 * list of package names (char*), it should be freed by the caller.
 * @param pkg a package
 * @return the list of packages optionally requiring pkg
 */
alpm_list_t *alpm_pkg_compute_optionalfor(alpm_pkg_t *pkg);

/** @name Package Property Accessors
 * Any pointer returned by these functions points to internal structures
 * allocated by libalpm. They should not be freed nor modified in any
 * way.
 * @{
 */

/** Gets the name of the file from which the package was loaded.
 * @param pkg a pointer to package
 * @return a reference to an internal string
 */
const char *alpm_pkg_get_filename(alpm_pkg_t *pkg);

/** Returns the package name.
 * @param pkg a pointer to package
 * @return a reference to an internal string
 */
const char *alpm_pkg_get_name(alpm_pkg_t *pkg);

/** Returns the package version as a string.
 * This includes all available epoch, version, and pkgrel components. Use
 * alpm_pkg_vercmp() to compare version strings if necessary.
 * @param pkg a pointer to package
 * @return a reference to an internal string
 */
const char *alpm_pkg_get_version(alpm_pkg_t *pkg);

/** Returns the origin of the package.
 * @return an alpm_pkgfrom_t constant, -1 on error
 */
alpm_pkgfrom_t alpm_pkg_get_origin(alpm_pkg_t *pkg);

/** Returns the package description.
 * @param pkg a pointer to package
 * @return a reference to an internal string
 */
const char *alpm_pkg_get_desc(alpm_pkg_t *pkg);

/** Returns the package URL.
 * @param pkg a pointer to package
 * @return a reference to an internal string
 */
const char *alpm_pkg_get_url(alpm_pkg_t *pkg);

/** Returns the build timestamp of the package.
 * @param pkg a pointer to package
 * @return the timestamp of the build time
 */
alpm_time_t alpm_pkg_get_builddate(alpm_pkg_t *pkg);

/** Returns the install timestamp of the package.
 * @param pkg a pointer to package
 * @return the timestamp of the install time
 */
alpm_time_t alpm_pkg_get_installdate(alpm_pkg_t *pkg);

/** Returns the packager's name.
 * @param pkg a pointer to package
 * @return a reference to an internal string
 */
const char *alpm_pkg_get_packager(alpm_pkg_t *pkg);

/** Returns the package's MD5 checksum as a string.
 * The returned string is a sequence of 32 lowercase hexadecimal digits.
 * @param pkg a pointer to package
 * @return a reference to an internal string
 */
const char *alpm_pkg_get_md5sum(alpm_pkg_t *pkg);

/** Returns the package's SHA256 checksum as a string.
 * The returned string is a sequence of 64 lowercase hexadecimal digits.
 * @param pkg a pointer to package
 * @return a reference to an internal string
 */
const char *alpm_pkg_get_sha256sum(alpm_pkg_t *pkg);

/** Returns the architecture for which the package was built.
 * @param pkg a pointer to package
 * @return a reference to an internal string
 */
const char *alpm_pkg_get_arch(alpm_pkg_t *pkg);

/** Returns the size of the package. This is only available for sync database
 * packages and package files, not those loaded from the local database.
 * @param pkg a pointer to package
 * @return the size of the package in bytes.
 */
alpm_off_t alpm_pkg_get_size(alpm_pkg_t *pkg);

/** Returns the installed size of the package.
 * @param pkg a pointer to package
 * @return the total size of files installed by the package.
 */
alpm_off_t alpm_pkg_get_isize(alpm_pkg_t *pkg);

/** Returns the package installation reason.
 * @param pkg a pointer to package
 * @return an enum member giving the install reason.
 */
alpm_pkgreason_t alpm_pkg_get_reason(alpm_pkg_t *pkg);

/** Returns the list of package licenses.
 * @param pkg a pointer to package
 * @return a pointer to an internal list of strings.
 */
alpm_list_t *alpm_pkg_get_licenses(alpm_pkg_t *pkg);

/** Returns the list of package groups.
 * @param pkg a pointer to package
 * @return a pointer to an internal list of strings.
 */
alpm_list_t *alpm_pkg_get_groups(alpm_pkg_t *pkg);

/** Returns the list of package dependencies as alpm_depend_t.
 * @param pkg a pointer to package
 * @return a reference to an internal list of alpm_depend_t structures.
 */
alpm_list_t *alpm_pkg_get_depends(alpm_pkg_t *pkg);

/** Returns the list of package optional dependencies.
 * @param pkg a pointer to package
 * @return a reference to an internal list of alpm_depend_t structures.
 */
alpm_list_t *alpm_pkg_get_optdepends(alpm_pkg_t *pkg);

/** Returns the list of packages conflicting with pkg.
 * @param pkg a pointer to package
 * @return a reference to an internal list of alpm_depend_t structures.
 */
alpm_list_t *alpm_pkg_get_conflicts(alpm_pkg_t *pkg);

/** Returns the list of packages provided by pkg.
 * @param pkg a pointer to package
 * @return a reference to an internal list of alpm_depend_t structures.
 */
alpm_list_t *alpm_pkg_get_provides(alpm_pkg_t *pkg);

/** Returns the list of available deltas for pkg.
 * @param pkg a pointer to package
 * @return a reference to an internal list of strings.
 */
alpm_list_t *alpm_pkg_get_deltas(alpm_pkg_t *pkg);

/** Returns the list of packages to be replaced by pkg.
 * @param pkg a pointer to package
 * @return a reference to an internal list of alpm_depend_t structures.
 */
alpm_list_t *alpm_pkg_get_replaces(alpm_pkg_t *pkg);

/** Returns the list of files installed by pkg.
 * The filenames are relative to the install root,
 * and do not include leading slashes.
 * @param pkg a pointer to package
 * @return a pointer to a filelist object containing a count and an array of
 * package file objects
 */
alpm_filelist_t *alpm_pkg_get_files(alpm_pkg_t *pkg);

/** Returns the list of files backed up when installing pkg.
 * The elements of the returned list have the form
 * "<filename>\t<md5sum>", where the given md5sum is that of
 * the file as provided by the package.
 * @param pkg a pointer to package
 * @return a reference to a list of alpm_backup_t objects
 */
alpm_list_t *alpm_pkg_get_backup(alpm_pkg_t *pkg);

/** Returns the database containing pkg.
 * Returns a pointer to the alpm_db_t structure the package is
 * originating from, or NULL if the package was loaded from a file.
 * @param pkg a pointer to package
 * @return a pointer to the DB containing pkg, or NULL.
 */
alpm_db_t *alpm_pkg_get_db(alpm_pkg_t *pkg);

/** Returns the base64 encoded package signature.
 * @param pkg a pointer to package
 * @return a reference to an internal string
 */
const char *alpm_pkg_get_base64_sig(alpm_pkg_t *pkg);

/** Returns the method used to validate a package during install.
 * @param pkg a pointer to package
 * @return an enum member giving the validation method
 */
alpm_pkgvalidation_t alpm_pkg_get_validation(alpm_pkg_t *pkg);

/* End of alpm_pkg_t accessors */
/* @} */

/** Open a package changelog for reading.
 * Similar to fopen in functionality, except that the returned 'file
 * stream' could really be from an archive as well as from the database.
 * @param pkg the package to read the changelog of (either file or db)
 * @return a 'file stream' to the package changelog
 */
void *alpm_pkg_changelog_open(alpm_pkg_t *pkg);

/** Read data from an open changelog 'file stream'.
 * Similar to fread in functionality, this function takes a buffer and
 * amount of data to read. If an error occurs pm_errno will be set.
 * @param ptr a buffer to fill with raw changelog data
 * @param size the size of the buffer
 * @param pkg the package that the changelog is being read from
 * @param fp a 'file stream' to the package changelog
 * @return the number of characters read, or 0 if there is no more data or an
 * error occurred.
 */
size_t alpm_pkg_changelog_read(void *ptr, size_t size,
		const alpm_pkg_t *pkg, void *fp);

int alpm_pkg_changelog_close(const alpm_pkg_t *pkg, void *fp);

/** Open a package mtree file for reading.
 * @param pkg the local package to read the changelog of
 * @return a archive structure for the package mtree file
 */
struct archive *alpm_pkg_mtree_open(alpm_pkg_t *pkg);

/** Read next entry from a package mtree file.
 * @param pkg the package that the mtree file is being read from
 * @param archive the archive structure reading from the mtree file
 * @param entry an archive_entry to store the entry header information
 * @return 0 if end of archive is reached, non-zero otherwise.
 */
int alpm_pkg_mtree_next(const alpm_pkg_t *pkg, struct archive *archive,
		struct archive_entry **entry);

int alpm_pkg_mtree_close(const alpm_pkg_t *pkg, struct archive *archive);

/** Returns whether the package has an install scriptlet.
 * @return 0 if FALSE, TRUE otherwise
 */
int alpm_pkg_has_scriptlet(alpm_pkg_t *pkg);

/** Returns the size of download.
 * Returns the size of the files that will be downloaded to install a
 * package.
 * @param newpkg the new package to upgrade to
 * @return the size of the download
 */
alpm_off_t alpm_pkg_download_size(alpm_pkg_t *newpkg);

alpm_list_t *alpm_pkg_unused_deltas(alpm_pkg_t *pkg);

/** Set install reason for a package in the local database.
 * The provided package object must be from the local database or this method
 * will fail. The write to the local database is performed immediately.
 * @param pkg the package to update
 * @param reason the new install reason
 * @return 0 on success, -1 on error (pm_errno is set accordingly)
 */
int alpm_pkg_set_reason(alpm_pkg_t *pkg, alpm_pkgreason_t reason);


/* End of alpm_pkg */
/** @} */

/*
 * Filelists
 */

/** Determines whether a package filelist contains a given path.
 * The provided path should be relative to the install root with no leading
 * slashes, e.g. "etc/localtime". When searching for directories, the path must
 * have a trailing slash.
 * @param filelist a pointer to a package filelist
 * @param path the path to search for in the package
 * @return a pointer to the matching file or NULL if not found
 */
char *alpm_filelist_contains(alpm_filelist_t *filelist, const char *path);

/*
 * Signatures
 */

int alpm_pkg_check_pgp_signature(alpm_pkg_t *pkg, alpm_siglist_t *siglist);

int alpm_db_check_pgp_signature(alpm_db_t *db, alpm_siglist_t *siglist);

int alpm_siglist_cleanup(alpm_siglist_t *siglist);

/*
 * Groups
 */

alpm_list_t *alpm_find_group_pkgs(alpm_list_t *dbs, const char *name);

/*
 * Sync
 */

alpm_pkg_t *alpm_sync_newversion(alpm_pkg_t *pkg, alpm_list_t *dbs_sync);

/** @addtogroup alpm_api_trans Transaction Functions
 * Functions to manipulate libalpm transactions
 * @{
 */

/** Transaction flags */
typedef enum _alpm_transflag_t {
	/** Ignore dependency checks. */
	ALPM_TRANS_FLAG_NODEPS = 1,
	/** Ignore file conflicts and overwrite files. */
	ALPM_TRANS_FLAG_FORCE = (1 << 1),
	/** Delete files even if they are tagged as backup. */
	ALPM_TRANS_FLAG_NOSAVE = (1 << 2),
	/** Ignore version numbers when checking dependencies. */
	ALPM_TRANS_FLAG_NODEPVERSION = (1 << 3),
	/** Remove also any packages depending on a package being removed. */
	ALPM_TRANS_FLAG_CASCADE = (1 << 4),
	/** Remove packages and their unneeded deps (not explicitly installed). */
	ALPM_TRANS_FLAG_RECURSE = (1 << 5),
	/** Modify database but do not commit changes to the filesystem. */
	ALPM_TRANS_FLAG_DBONLY = (1 << 6),
	/* (1 << 7) flag can go here */
	/** Use ALPM_PKG_REASON_DEPEND when installing packages. */
	ALPM_TRANS_FLAG_ALLDEPS = (1 << 8),
	/** Only download packages and do not actually install. */
	ALPM_TRANS_FLAG_DOWNLOADONLY = (1 << 9),
	/** Do not execute install scriptlets after installing. */
	ALPM_TRANS_FLAG_NOSCRIPTLET = (1 << 10),
	/** Ignore dependency conflicts. */
	ALPM_TRANS_FLAG_NOCONFLICTS = (1 << 11),
	/* (1 << 12) flag can go here */
	/** Do not install a package if it is already installed and up to date. */
	ALPM_TRANS_FLAG_NEEDED = (1 << 13),
	/** Use ALPM_PKG_REASON_EXPLICIT when installing packages. */
	ALPM_TRANS_FLAG_ALLEXPLICIT = (1 << 14),
	/** Do not remove a package if it is needed by another one. */
	ALPM_TRANS_FLAG_UNNEEDED = (1 << 15),
	/** Remove also explicitly installed unneeded deps (use with ALPM_TRANS_FLAG_RECURSE). */
	ALPM_TRANS_FLAG_RECURSEALL = (1 << 16),
	/** Do not lock the database during the operation. */
	ALPM_TRANS_FLAG_NOLOCK = (1 << 17)
} alpm_transflag_t;

/** Returns the bitfield of flags for the current transaction.
 * @param handle the context handle
 * @return the bitfield of transaction flags
 */
alpm_transflag_t alpm_trans_get_flags(alpm_handle_t *handle);

/** Returns a list of packages added by the transaction.
 * @param handle the context handle
 * @return a list of alpm_pkg_t structures
 */
alpm_list_t *alpm_trans_get_add(alpm_handle_t *handle);

/** Returns the list of packages removed by the transaction.
 * @param handle the context handle
 * @return a list of alpm_pkg_t structures
 */
alpm_list_t *alpm_trans_get_remove(alpm_handle_t *handle);

/** Initialize the transaction.
 * @param handle the context handle
 * @param flags flags of the transaction (like nodeps, etc)
 * @return 0 on success, -1 on error (pm_errno is set accordingly)
 */
int alpm_trans_init(alpm_handle_t *handle, alpm_transflag_t flags);

/** Prepare a transaction.
 * @param handle the context handle
 * @param data the address of an alpm_list where a list
 * of alpm_depmissing_t objects is dumped (conflicting packages)
 * @return 0 on success, -1 on error (pm_errno is set accordingly)
 */
int alpm_trans_prepare(alpm_handle_t *handle, alpm_list_t **data);

/** Commit a transaction.
 * @param handle the context handle
 * @param data the address of an alpm_list where detailed description
 * of an error can be dumped (i.e. list of conflicting files)
 * @return 0 on success, -1 on error (pm_errno is set accordingly)
 */
int alpm_trans_commit(alpm_handle_t *handle, alpm_list_t **data);

/** Interrupt a transaction.
 * @param handle the context handle
 * @return 0 on success, -1 on error (pm_errno is set accordingly)
 */
int alpm_trans_interrupt(alpm_handle_t *handle);

/** Release a transaction.
 * @param handle the context handle
 * @return 0 on success, -1 on error (pm_errno is set accordingly)
 */
int alpm_trans_release(alpm_handle_t *handle);
/** @} */

/** @name Common Transactions */
/** @{ */

/** Search for packages to upgrade and add them to the transaction.
 * @param handle the context handle
 * @param enable_downgrade allow downgrading of packages if the remote version is lower
 * @return 0 on success, -1 on error (pm_errno is set accordingly)
 */
int alpm_sync_sysupgrade(alpm_handle_t *handle, int enable_downgrade);

/** Add a package to the transaction.
 * If the package was loaded by alpm_pkg_load(), it will be freed upon
 * alpm_trans_release() invocation.
 * @param handle the context handle
 * @param pkg the package to add
 * @return 0 on success, -1 on error (pm_errno is set accordingly)
 */
int alpm_add_pkg(alpm_handle_t *handle, alpm_pkg_t *pkg);

/** Add a package removal action to the transaction.
 * @param handle the context handle
 * @param pkg the package to uninstall
 * @return 0 on success, -1 on error (pm_errno is set accordingly)
 */
int alpm_remove_pkg(alpm_handle_t *handle, alpm_pkg_t *pkg);

/** @} */

/** @addtogroup alpm_api_depends Dependency Functions
 * Functions dealing with libalpm representation of dependency
 * information.
 * @{
 */

alpm_list_t *alpm_checkdeps(alpm_handle_t *handle, alpm_list_t *pkglist,
		alpm_list_t *remove, alpm_list_t *upgrade, int reversedeps);
alpm_pkg_t *alpm_find_satisfier(alpm_list_t *pkgs, const char *depstring);
alpm_pkg_t *alpm_find_dbs_satisfier(alpm_handle_t *handle,
		alpm_list_t *dbs, const char *depstring);

alpm_list_t *alpm_checkconflicts(alpm_handle_t *handle, alpm_list_t *pkglist);

/** Returns a newly allocated string representing the dependency information.
 * @param dep a dependency info structure
 * @return a formatted string, e.g. "glibc>=2.12"
 */
char *alpm_dep_compute_string(const alpm_depend_t *dep);

/** @} */

/** @} */

/*
 * Helpers
 */

/* checksums */
char *alpm_compute_md5sum(const char *filename);
char *alpm_compute_sha256sum(const char *filename);

/** @addtogroup alpm_api_errors Error Codes
 * @{
 */
typedef enum _alpm_errno_t {
	ALPM_ERR_MEMORY = 1,
	ALPM_ERR_SYSTEM,
	ALPM_ERR_BADPERMS,
	ALPM_ERR_NOT_A_FILE,
	ALPM_ERR_NOT_A_DIR,
	ALPM_ERR_WRONG_ARGS,
	ALPM_ERR_DISK_SPACE,
	/* Interface */
	ALPM_ERR_HANDLE_NULL,
	ALPM_ERR_HANDLE_NOT_NULL,
	ALPM_ERR_HANDLE_LOCK,
	/* Databases */
	ALPM_ERR_DB_OPEN,
	ALPM_ERR_DB_CREATE,
	ALPM_ERR_DB_NULL,
	ALPM_ERR_DB_NOT_NULL,
	ALPM_ERR_DB_NOT_FOUND,
	ALPM_ERR_DB_INVALID,
	ALPM_ERR_DB_INVALID_SIG,
	ALPM_ERR_DB_VERSION,
	ALPM_ERR_DB_WRITE,
	ALPM_ERR_DB_REMOVE,
	/* Servers */
	ALPM_ERR_SERVER_BAD_URL,
	ALPM_ERR_SERVER_NONE,
	/* Transactions */
	ALPM_ERR_TRANS_NOT_NULL,
	ALPM_ERR_TRANS_NULL,
	ALPM_ERR_TRANS_DUP_TARGET,
	ALPM_ERR_TRANS_NOT_INITIALIZED,
	ALPM_ERR_TRANS_NOT_PREPARED,
	ALPM_ERR_TRANS_ABORT,
	ALPM_ERR_TRANS_TYPE,
	ALPM_ERR_TRANS_NOT_LOCKED,
	/* Packages */
	ALPM_ERR_PKG_NOT_FOUND,
	ALPM_ERR_PKG_IGNORED,
	ALPM_ERR_PKG_INVALID,
	ALPM_ERR_PKG_INVALID_CHECKSUM,
	ALPM_ERR_PKG_INVALID_SIG,
	ALPM_ERR_PKG_OPEN,
	ALPM_ERR_PKG_CANT_REMOVE,
	ALPM_ERR_PKG_INVALID_NAME,
	ALPM_ERR_PKG_INVALID_ARCH,
	ALPM_ERR_PKG_REPO_NOT_FOUND,
	/* Signatures */
	ALPM_ERR_SIG_MISSING,
	ALPM_ERR_SIG_INVALID,
	/* Deltas */
	ALPM_ERR_DLT_INVALID,
	ALPM_ERR_DLT_PATCHFAILED,
	/* Dependencies */
	ALPM_ERR_UNSATISFIED_DEPS,
	ALPM_ERR_CONFLICTING_DEPS,
	ALPM_ERR_FILE_CONFLICTS,
	/* Misc */
	ALPM_ERR_RETRIEVE,
	ALPM_ERR_INVALID_REGEX,
	/* External library errors */
	ALPM_ERR_LIBARCHIVE,
	ALPM_ERR_LIBCURL,
	ALPM_ERR_EXTERNAL_DOWNLOAD,
	ALPM_ERR_GPGME
} alpm_errno_t;

/** Returns the current error code from the handle. */
alpm_errno_t alpm_errno(alpm_handle_t *handle);

/** Returns the string corresponding to an error number. */
const char *alpm_strerror(alpm_errno_t err);

/* End of alpm_api_errors */
/** @} */

alpm_handle_t *alpm_initialize(const char *root, const char *dbpath,
		alpm_errno_t *err);
int alpm_release(alpm_handle_t *handle);

enum alpm_caps {
	ALPM_CAPABILITY_NLS = (1 << 0),
	ALPM_CAPABILITY_DOWNLOADER = (1 << 1),
	ALPM_CAPABILITY_SIGNATURES = (1 << 2)
};

const char *alpm_version(void);
enum alpm_caps alpm_capabilities(void);

/* End of alpm_api */
/** @} */

/* vim: set ts=2 sw=2 noet: */
]]

M.Db = ffi.metatype("alpm_db_t", { __index = {
    unregister = lib.alpm_db_unregister,
    get_name = lib.alpm_db_get_name,
    get_siglevel = lib.alpm_db_get_siglevel,
    get_valid = lib.alpm_db_get_valid,
    get_servers = lib.alpm_db_get_servers,
    set_servers = lib.alpm_db_set_servers,
    add_server = lib.alpm_db_add_server,
    remove_server = lib.alpm_db_remove_server,
    update = function(self, force) return lib.alpm_db_update(force or 0, self) end,
    get_pkg = lib.alpm_db_get_pkg,
    get_pkgcache = lib.alpm_db_get_pkgcache,
    get_group = lib.alpm_db_get_group,
    get_groupcache = lib.alpm_db_get_groupcache,
    search = lib.alpm_db_search,
    check_pgp_signature = lib.alpm_db_check_pgp_signature,
}})

M.Pkg = ffi.metatype("alpm_pkg_t", {__index = {
    free = lib.alpm_pkg_free,
    checkmd5sum = lib.alpm_pkg_checkmd5sum,
    compute_requiredby = lib.alpm_pkg_compute_requiredby,
    compute_optionalfor = lib.alpm_pkg_compute_optionalfor,
    get_filename = lib.alpm_pkg_get_filename,
    get_name = lib.alpm_pkg_get_name,
    get_version = lib.alpm_pkg_get_version,
    get_origin = lib.alpm_pkg_get_origin,
    get_desc = lib.alpm_pkg_get_desc,
    get_url = lib.alpm_pkg_get_url,
    get_builddate = lib.alpm_pkg_get_builddate,
    get_installdate = lib.alpm_pkg_get_installdate,
    get_packager = lib.alpm_pkg_get_packager,
    get_md5sum = lib.alpm_pkg_get_md5sum,
    get_sha256sum = lib.alpm_pkg_get_sha256sum,
    get_arch = lib.alpm_pkg_get_arch,
    get_size = lib.alpm_pkg_get_size,
    get_isize = lib.alpm_pkg_get_isize,
    get_reason = lib.alpm_pkg_get_reason,
    get_licenses = lib.alpm_pkg_get_licenses,
    get_groups = lib.alpm_pkg_get_groups,
    get_depends = lib.alpm_pkg_get_depends,
    get_optdepends = lib.alpm_pkg_get_optdepends,
    get_conflicts = lib.alpm_pkg_get_conflicts,
    get_provides = lib.alpm_pkg_get_provides,
    get_deltas = lib.alpm_pkg_get_deltas,
    get_replaces = lib.alpm_pkg_get_replaces,
    get_files = lib.alpm_pkg_get_files,
    get_backup = lib.alpm_pkg_get_backup,
    get_db = lib.alpm_pkg_get_db,
    get_base64_sig = lib.alpm_pkg_get_base64_sig,
    get_validation = lib.alpm_pkg_get_validation,
    changelog_open = lib.alpm_pkg_changelog_open,
    changelog_read = function(pkg, ptr, size, fp) return lib.alpm_pkg_changelog_read(ptr, size, pkg, fp) end,
    changelog_close = lib.alpm_pkg_changelog_close,
    mtree_open = lib.alpm_pkg_mtree_open,
    mtree_next = lib.alpm_pkg_mtree_next,
    mtree_close = lib.alpm_pkg_mtree_close,
    has_scriptlet = lib.alpm_pkg_has_scriptlet,
    download_size = lib.alpm_pkg_download_size,
    unused_deltas = lib.alpm_pkg_unused_deltas,
    set_reason = lib.alpm_pkg_set_reason,
    check_pgp_signature = lib.alpm_pkg_check_pgp_signature,
    vercmp = function(a, b, c)
        if c then a=b;b=c end
        return lib.alpm_pkg_vercmp(a, b)
    end
}})
M.Errno=ffi.typeof("alpm_errno_t[1]")
M.Alpm = ffi.metatype("alpm_handle_t", {__index = {
  initialize = function(root, dbpath, errno)
    local a = lib.alpm_initialize(root, dbpath, errno)
    if not a then return nil end
    return ffi.gc(a,function(v) lib.unregister_all_syncdbs(v);lib.alpm_release(v) end)
  end,
  logaction = lib.alpm_logaction,
  option_get_logcb = lib.alpm_option_get_logcb,
  option_set_logcb = lib.alpm_option_set_logcb,
  option_get_dlcb = lib.alpm_option_get_dlcb,
  option_set_dlcb = lib.alpm_option_set_dlcb,
  option_get_fetchcb = lib.alpm_option_get_fetchcb,
  option_set_fetchcb = lib.alpm_option_set_fetchcb,
  option_get_totaldlcb = lib.alpm_option_get_totaldlcb,
  option_set_totaldlcb = lib.alpm_option_set_totaldlcb,
  option_get_eventcb = lib.alpm_option_get_eventcb,
  option_set_eventcb = lib.alpm_option_set_eventcb,
  option_get_questioncb = lib.alpm_option_get_questioncb,
  option_set_questioncb = lib.alpm_option_set_questioncb,
  option_get_progresscb = lib.alpm_option_get_progresscb,
  option_set_progresscb = lib.alpm_option_set_progresscb,
  option_set_cachedirs = lib.alpm_option_set_cachedirs,
  option_add_cachedir = lib.alpm_option_add_cachedir,
  option_remove_cachedir = lib.alpm_option_remove_cachedir,
  option_set_logfile = lib.alpm_option_set_logfile,
  option_set_gpgdir = lib.alpm_option_set_gpgdir,
  option_get_usesyslog = lib.alpm_option_get_usesyslog,
  option_set_usesyslog = lib.alpm_option_set_usesyslog,
  option_add_noupgrade = lib.alpm_option_add_noupgrade,
  option_set_noupgrades = lib.alpm_option_set_noupgrades,
  option_remove_noupgrade = lib.alpm_option_remove_noupgrade,
  option_add_noextract = lib.alpm_option_add_noextract,
  option_set_noextracts = lib.alpm_option_set_noextracts,
  option_remove_noextract = lib.alpm_option_remove_noextract,
  option_add_ignorepkg = lib.alpm_option_add_ignorepkg,
  option_set_ignorepkgs = lib.alpm_option_set_ignorepkgs,
  option_remove_ignorepkg = lib.alpm_option_remove_ignorepkg,
  option_add_ignoregroup = lib.alpm_option_add_ignoregroup,
  option_set_ignoregroups = lib.alpm_option_set_ignoregroups,
  option_remove_ignoregroup = lib.alpm_option_remove_ignoregroup,
  option_set_arch = lib.alpm_option_set_arch,
  option_get_deltaratio = lib.alpm_option_get_deltaratio,
  option_set_deltaratio = lib.alpm_option_set_deltaratio,
  option_get_checkspace = lib.alpm_option_get_checkspace,
  option_set_checkspace = lib.alpm_option_set_checkspace,
  option_get_default_siglevel = lib.alpm_option_get_default_siglevel,
  option_set_default_siglevel = lib.alpm_option_set_default_siglevel,
  option_get_local_file_siglevel = lib.alpm_option_get_local_file_siglevel,
  option_set_local_file_siglevel = lib.alpm_option_set_local_file_siglevel,
  option_get_remote_file_siglevel = lib.alpm_option_get_remote_file_siglevel,
  option_set_remote_file_siglevel = lib.alpm_option_set_remote_file_siglevel,
  get_localdb = lib.alpm_get_localdb,
  get_syncdbs = lib.alpm_get_syncdbs,
  unregister_all_syncdbs = lib.alpm_unregister_all_syncdbs,
  pkg_load = lib.alpm_pkg_load,
  trans_get_flags = lib.alpm_trans_get_flags,
  trans_init = lib.alpm_trans_init,
  trans_prepare = lib.alpm_trans_prepare,
  trans_commit = lib.alpm_trans_commit,
  trans_interrupt = lib.alpm_trans_interrupt,
  trans_release = lib.alpm_trans_release,
  sync_sysupgrade = lib.alpm_sync_sysupgrade,
  add_pkg = lib.alpm_add_pkg,
  remove_pkg = lib.alpm_remove_pkg,
  errno = lib.alpm_errno,
  strerror = function(self, v) return lib.alpm_strerror(v or lib.alpm_errno()) end,
  release = lib.alpm_release,
}})

M.Dep = ffi.metatype("alpm_depend_t", {__index={
    compute_string = lib.alpm_dep_compute_string
}})


M.Filelist = ffi.metatype("alpm_filelist_t", {__index={
    contains = lib.alpm_filelist_contains
}})

M.Siglist = ffi.metatype("alpm_siglist_t", {__index={
    cleanup = lib.alpm_siglist_cleanup
}})

M.find_group_pkgs = lib.alpm_find_group_pkgs
M.sync_newversion = lib.alpm_sync_newversion

M.strerror=function(e) return ffi.string(lib.alpm_strerror(e)) end
M.version = function() return ffi.string(lib.alpm_version()) end
M.capabilities = function()
    local c = tonumber(lib.alpm_capabilities())
    local t={}
    if bit.band(1, c) == 1 then t[#t+1]='NLS' end
    if bit.band(2, c) == 1 then t[#t+1]='DOWNLOADER' end
    if bit.band(4, c) == 1 then t[#t+1]='SIGNATURES' end
    return table.concat(t, ", ")
 end

M.checkdeps = lib.alpm_checkdeps
M.find_satisfier = lib.alpm_find_satisfier
M.find_dbs_satisfier = lib.alpm_find_dbs_satisfier
M.checkconflicts = lib.alpm_checkconflicts
M.compute_md5sum = lib.alpm_compute_md5sum
M.compute_sha256sum = lib.alpm_compute_sha256sum

M.Pkgref = ffi.typeof("alpm_pkg_t*")
M.Dbref = ffi.typeof("alpm_db_t*")
M.Listref = ffi.typeof("alpm_list_t*")
M.String = ffi.string

return M
