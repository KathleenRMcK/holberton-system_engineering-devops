my $filename = shift;
my $linenr=0;
my $prevline="";
my $prevrawline="";
my $stashline="";
my $stashrawline="";
my $length;
my $real_length;
my $indent;
my $previndent=0;
my $stashindent=0;
# Header protection
my $header_protected = 0;
my $protection_name = '';
my $header_if_depth = 0;
our $clean = 1;
my $signoff = 0;
my $is_patch = 0;
my $in_header_lines = $file ? 0 : 1;
my $in_commit_log = 0;#Scanning lines before patch
my $commit_log_long_line = 0;
my $commit_log_has_diff = 0;
my $reported_maintainer_file = 0;
my $non_utf8_charset = 0;
my $last_blank_line = 0;
my $last_coalesced_string_linenr = -1;
our @report = ();
our $cnt_lines = 0;
our $cnt_error = 0;
our $cnt_warn = 0;
our $cnt_chk = 0;
# Trace the real file/line as we go.
my $realfile = '';
my $realline = 0;
my $realcnt = 0;
my $here = '';
my $in_comment = 0;
my $comment_edge = 0;
my $first_line = 0;
my $p1_prefix = '';
my $prev_values = 'E';
# suppression flags
my %suppress_ifbraces;
my %suppress_whiletrailers;
my %suppress_export;
my $suppress_statement = 0;
my %signatures = ();
# Pre-scan the patch sanitizing the lines.
# Pre-scan the patch looking for any __setup documentation.
#
my @setup_docs = ();
my $setup_docs = 0;
my $camelcase_file_seeded = 0;
sanitise_line_reset();
my $line;
foreach my $rawline (@rawlines) {
$linenr++;
$line = $rawline;
push(@fixed, $rawline) if ($fix);
if ($rawline=~/^\+\+\+\s+(\S+)/) {
$setup_docs = 0;
if ($1 =~ m@Documentation/kernel-parameters.txt$@) {
$setup_docs = 1;
}
#next;
}
if ($rawline=~/^\@\@ -\d+(?:,\d+)? \+(\d+)(,(\d+))? \@\@/) {
$realline=$1-1;
if (defined $2) {
$realcnt=$3+1;
} else {
$realcnt=1+1;
}
$in_comment = 0;
# Guestimate if this is a continuing comment.  Run
# the context looking for a comment "edge".  If this
# edge is a close comment then we must be in a comment
# at context start.
my $edge;
my $cnt = $realcnt;
for (my $ln = $linenr + 1; $cnt > 0; $ln++) {
next if (defined $rawlines[$ln - 1] &&
$cnt--;
#print "RAW<$rawlines[$ln - 1]>\n";
if ($rawlines[$ln - 1] =~ m@(/\*|\*/)@ && ed $edge && $edge eq '*/') {
$in_comment = 1;
}
# Guestimate if this is a continuing comment.  If this
# is the start of a diff block and this line starts
# ' *' then it is very likely a comment.
{ _comment = 1; t "COMMENT:$in_comment edge<$edge> $rawline\n"; itise_line_reset($in_comment);
} elsif ($realcnt && $rawline =~ /^(?:\+| |$)/) {
# Standardise the strings and chars within the input to
# simplify matching -- only bother with positive lines.
$line = sanitise_line($rawline);
}
push(@lines, $line);
if ($realcnt > 1) {
$realcnt-- if ($line =~ /^(?:\+| |$)/);
} else {
$realcnt = 0;
}
#print "==>$rawline\n";
#print "-->$line\n";
if ($setup_docs && $line =~ /^\+/) {
push(@setup_docs, $line);
}
$prefix = '';
$realcnt = 0;
$linenr = 0;
$fixlinenr = -1;
my $nbfunc = 0;
my $infunc = 0;
my $infuncproto = 0;
my $funcprotovalid = 0; # Prevline ended a valid function prototype (no trailing ';')
my $inscope = 0;
my $funclines = 0;
foreach my $line (@lines) {
$linenr++;
$fixlinenr++;
my $sline = $line;#copy of $line
$sline =~ s/$;/ /g;#with comments as spaces
my $rawline = $rawlines[$linenr - 1];
#extract the line range in the file after the patch is applied
if (#extract the line range in the file after the patch is appliedin_commit_log && e =~ /^\@\@ -\d+(?:,\d+)? \+(\d+)(,(\d+))? \@\@/) {
$is_patch = 1;
$first_line = $linenr + 1;
$realline=$1-1;
if (defined $2) {
$realcnt=$3+1;
} else {
$realcnt=1+1;
}
annotate_reset();
$prev_values = 'E';
%suppress_ifbraces = ();
%suppress_whiletrailers = ();
%suppress_export = ();
$suppress_statement = 0;
next;
# track the line number as we move through the hunk, note that
# new versions of GNU diff omit the leading space on completely
# blank context lines so we need to count that too.
} elsif ($line =~ /^( |\+|$)/) {
$realline++;
$realcnt-- if ($realcnt != 0);
# Measure the line length and indent.
($length, $indent) = line_stats($rawline);
$real_length = real_length($rawline);
# Track the previous line.
($prevline, $stashline) = ($stashline, $line);
($previndent, $stashindent) = ($stashindent, $indent);
($prevrawline, $stashrawline) = ($stashrawline, $rawline);
#warn "line<$line>\n";
} elsif ($realcnt == 1) {
$realcnt--;
}
my $hunk_line = ($realcnt != 0);
$here = "#$linenr: " if (;file);
$here = "#$realline: " if ($file);
my $found_file = 0;
# extract the filename as it passes
if ($line =~ /^diff --git.*?(\S+)$/) {
$realfile = $1;
$realfile =~ s@^([^/]*)/@@ if (;file);
$in_commit_log = 0;
$found_file = 1;
} elsif ($line =~ /^\+\+\+\s+(\S+)/) {
$realfile = $1;
$realfile =~ s@^([^/]*)/@@ if (;file);
$in_commit_log = 0;
$p1_prefix = $1;
if (;file && $tree && $p1_prefix ne '' &&
WARN("PATCH_PREFIX",
}
if ($realfile =~ m@^include/asm/@) {
ERROR("MODIFIED_INCLUDE_ASM",
}
$found_file = 1;
}
#make up the handle for any error we report on this line
if ($showfile) {
$prefix = "$realfile:$realline: "
} elsif ($emacs) {
if ($file) {
$prefix = "$filename:$realline: ";
} else {
$prefix = "$filename:$linenr: ";
}
if ($found_file) {
if ($realfile =~ m@^(?:drivers/net/|net/|drivers/staging/)@) {
$check = 1;
} else {
$check = $check_orig;
}
next;
}
$here .= "FILE: $realfile:$realline:" if ($realcnt != 0);
my $hereline = "$here\n$rawline\n";
my $herecurr = "$here\n$rawline\n";
my $hereprev = "$here\n$prevrawline\n$rawline\n";
$cnt_lines++ if ($realcnt != 0);
# Check if the commit log has what seems like a diff which can confuse patch
if ($in_commit_log && # Check if the commit log has what seems like a diff which can confuse patchcommit_log_has_diff && e =~ m@^\s+diff\b.*a/[\w/]+@ && e =~ m@^\s+diff\b.*a/([\w/]+)\s+b/$1\b@) ||
ERROR("DIFF_IN_COMMIT_MSG",
$commit_log_has_diff = 1;
}
# Check for incorrect file permissions
if ($line =~ /^new (file )?mode.*[7531]\d{0,2}$/) {
my $permhere = $here . "FILE: $realfile\n";
ERROR("EXECUTE_PERMISSIONS",
}
# Check the patch for a signoff:
if ($line =~ /^\s*signed-off-by:/i) {
$signoff++;
$in_commit_log = 0;
}
# Check if MAINTAINERS is being updated.  If so, there's probably no need to
# emit the "does MAINTAINERS need updating?" message on file add/move/delete
if ($line =~ /^\s*MAINTAINERS\s*\|/) {
$reported_maintainer_file = 1;
}
# Check signature styles
if (# Check signature stylesin_header_lines && e =~ /^(\s*)([a-z0-9_-]+by:|$signature_tags)(\s*)(.*)/i) {
my $space_before = $1;
my $sign_off = $2;
my $space_after = $3;
my $email = $4;
my $ucfirst_sign_off = ucfirst(lc($sign_off));
WARN("BAD_SIGN_OFF",
}
if (defined $space_before && $space_before ne "") {
if (WARN("BAD_SIGN_OFF",
$fixed[$fixlinenr] =
}
if ($sign_off =~ /-by:$/i && $sign_off ne $ucfirst_sign_off) {
if (WARN("BAD_SIGN_OFF",
$fixed[$fixlinenr] =
}
if (WARN("BAD_SIGN_OFF",
$fixed[$fixlinenr] =
}
my ($email_name, $email_address, $comment) = parse_email($email);
my $suggested_email = format_email(($email_name, $email_address));
if ($suggested_email eq "") {
ERROR("BAD_SIGN_OFF",
} else {
my $dequoted = $suggested_email;
$dequoted =~ s/^"//;
$dequoted =~ s/" </ </;
# Don't force email to have quotes
# Allow just an angle bracketed address
if ("$dequoted$comment" ne $email && t" ne $email &&
t" ne $email) {
WARN("BAD_SIGN_OFF",
}
# Check for duplicate signatures
my $sig_nospace = $line;
$sig_nospace =~ s/\s//g;
$sig_nospace = lc($sig_nospace);
if (defined $signatures{$sig_nospace}) {
WARN("BAD_SIGN_OFF",
} else {
$signatures{$sig_nospace} = 1;
}
# Check email subject for common tools that don't need to be mentioned
if ($in_header_lines && e =~ /^Subject:.*\b(?:checkpatch|sparse|smatch)\b[^:]/i) {
WARN("EMAIL_SUBJECT",
}
# Check for old stable address
if ($line =~ /^\s*cc:\s*.*<?\bstable\@kernel\.org\b>?.*$/i) {
ERROR("STABLE_ADDRESS",
}
# Check for unwanted Gerrit info
if ($in_commit_log && $line =~ /^\s*change-id:/i) {
ERROR("GERRIT_CHANGE_ID",
}
# Check if the commit log is in a possible stack dump
if ($in_commit_log && # Check if the commit log is in a possible stack dumpcommit_log_possible_stack_dump && e =~ /^\s*(?:WARNING:|BUG:)/ || e =~ /^\s*\[\s*\d+\.\d{6,6}\s*\]/ || e =~ /^\s*\[\<[0-9a-fA-F]{8,}\>\]/)) {
# stack dump address
$commit_log_possible_stack_dump = 1;
}
# Check for line lengths > 75 in commit log, warn once
if ($in_commit_log && # Check for line lengths > 75 in commit log, warn oncecommit_log_long_line && gth($line) > 75 &&
# file delta changes
WARN("COMMIT_LOG_LONG_LINE",
$commit_log_long_line = 1;
}
# Reset possible stack dump if a blank line is found
if ($in_commit_log && $commit_log_possible_stack_dump && e =~ /^\s*$/) {
$commit_log_possible_stack_dump = 0;
}
# Check for git id commit length and improperly formed commit descriptions
if ($in_commit_log && # Check for git id commit length and improperly formed commit descriptionscommit_log_possible_stack_dump && e =~ /\bcommit\s+[0-9a-f]{5,}\b/i || e =~ /\b[0-9a-f]{12,40}\b/i && it_char = "c"; g = 0; s = 0; ";
 = "";

e =~ /\b(c)ommit\s+([0-9a-f]{5,})\b/i) {
it_char = $1;
e =~ /\b([0-9a-f]{12,40})\b/i) {
e =~ /\bcommit\s+[0-9a-f]{12,40}/i);
g = 1 if ($line =~ /\bcommit\s+[0-9a-f]{41,}/i);
e =~ /\bcommit [0-9a-f]/i);
e =~ /\b[Cc]ommit\s+[0-9a-f]{5,40}[^A-F]/);
e =~ /\bcommit\s+[0-9a-f]{5,}\s+\("([^"]+)"\)/i) {
$orig_desc = $1;
$hasparens = 1;
} elsif ($line =~ /\bcommit\s+[0-9a-f]{5,}\s*$/i &&
$orig_desc = $1;
$hasparens = 1;
} elsif ($line =~ /\bcommit\s+[0-9a-f]{5,}\s+\("[^"]+$/i &&
$line =~ /\bcommit\s+[0-9a-f]{5,}\s+\("([^"]+)$/i;
$orig_desc = $1;
$rawlines[$linenr] =~ /^\s*([^"]+)"\)/;
$orig_desc .= " " . $1;
$hasparens = 1;
}

($id, $description) = git_commit_info($orig_commit,
      $id, $orig_desc);

if ($short || $long || $space || $case || ($orig_desc ne $description) || 
hasparens) {
ERROR("GIT_COMMIT_ID",
      "Please use git commit description style 'commit <12+ chars of sha1> (\"<title line>\")' - ie: '${init_char}ommit $id (\"$description\")'\n" . $herecurr);
}
}

# Check for added, moved or deleted files
if (
reported_maintainer_file && 
in_commit_log &&
    ($line =~ /^(?:new|deleted) file mode\s*\d+\s*$/ ||
     $line =~ /^rename (?:from|to) [\w\/\.\-]+\s*$/ ||
     ($line =~ /\{\s*([\w\/\.\-]*)\s*\=\>\s*([\w\/\.\-]*)\s*\}/ &&
      (defined($1) || defined($2))))) {
$reported_maintainer_file = 1;
WARN("FILE_PATH_CHANGES",
     "added, moved or deleted file(s), does MAINTAINERS need updating?\n" . $herecurr);
}

# Check for wrappage within a valid hunk of the file
ERROR("CORRUPTED_PATCH",
      "patch seems to be corrupt (line wrapped?)\n" .
$herecurr) if (
emitted_corrupt++);
}

# Check for absolute kernel paths.
if ($tree) {
while ($line =~ m{(?:^|\s)(/\S*)}g) {
my $file = $1;

if ($file =~ m{^(.*?)(?::\d+)+:?$} &&
    check_absolute_file($1, $herecurr)) {
#
} else {
check_absolute_file($file, $herecurr);
}
}
}

# UTF-8 regex found at http://www.w3.org/International/questions/qa-forms-utf-8.en.php
if (($realfile =~ /^$/ || $line =~ /^\+/) &&
my ($utf8_prefix) = ($rawline =~ /^($UTF8*)/);

my $blank = copy_spacing($rawline);
my $ptr = substr($blank, 0, length($utf8_prefix)) . "^";
my $hereptr = "$hereline$ptr\n";

CHK("INVALID_UTF8",
    "Invalid UTF-8, patch and commit message should be encoded in UTF-8\n" . $hereptr);
}

# Check if it's the start of a commit log
# (not a header line and we haven't seen the patch filename)
if ($in_header_lines && $realfile =~ /^$/ &&
      $rawline =~ /^(commit\b|from\b|[\w-]+:).*$/i)) {
$in_header_lines = 0;
$in_commit_log = 1;
}
# Check if there is UTF-8 in a commit log when a mail header has explicitly
# declined it, i.e defined some charset where it is missing.
if ($in_header_lines && e =~ /^Content-Type:.+charset="(.+)".*$/ && on_utf8_charset = 1; _commit_log && $non_utf8_charset && $realfile =~ /^$/ && e =~ /$NON_ASCII_UTF8/) {
WARN("UTF8_BEFORE_PATCH",
}
# Check for various typo / spelling mistakes
if (defined($misspellings) &&
while ($rawline =~ /(?:^|[^a-z@])($misspellings)(?:\b|$|[^a-z@])/gi) {
my $typo = $1;
my $typo_fix = $spelling_fix{lc($typo)};
$typo_fix = ucfirst($typo_fix) if ($typo =~ /^[A-Z]/);
$typo_fix = uc($typo_fix) if ($typo =~ /^[A-Z]+$/);
my $msg_type = \&WARN;
$msg_type = \&CHK if ($file);
if (&{$msg_type}("TYPO_SPELLING",
$fixed[$fixlinenr] =~ s/(^|[^A-Za-z@])($typo)($|[^A-Za-z@])/$1$typo_fix$3/;
}
# ignore non-hunk lines and lines being removed
next if (# ignore non-hunk lines and lines being removedhunk_line || $line =~ /^-/);
#trailing whitespace
if ($line =~ /^\+.*\015/) {
my $herevet = "$here\n" . cat_vet($rawline) . "\n";
if (ERROR("DOS_LINE_ENDINGS",
$fixed[$fixlinenr] =~ s/[\s\015]+$//;
}
} elsif ($rawline =~ /^\+.*\S\s+$/ || $rawline =~ /^\+\s+$/) {
my $herevet = "$here\n" . cat_vet($rawline) . "\n";
if (ERROR("TRAILING_WHITESPACE",
$fixed[$fixlinenr] =~ s/\s+$//;
}
$rpt_cleaners = 1;
}
# Check for FSF mailing addresses.
if ($rawline =~ /\bwrite to the Free/i || e =~ /\b59\s+Temple\s+Pl/i || e =~ /\b51\s+Franklin\s+St/i) {
my $herevet = "$here\n" . cat_vet($rawline) . "\n";
my $msg_type = \&ERROR;
$msg_type = \&CHK if ($file);
&{$msg_type}("FSF_MAILING_ADDRESS",
}
# check for Kconfig help text having a real description
# Only applies when adding the entry originally, after that we do not have
# sufficient context to determine whether it is indeed long enough.
if ($realfile =~ /Kconfig/ && e =~ /^\+\s*config\s+/) {
my $length = 0;
my $cnt = $realcnt;
my $ln = $linenr + 1;
my $f;
my $is_start = 0;
my $is_end = 0;
for (; $cnt > 0 && defined $lines[$ln - 1]; $ln++) {
$f = $lines[$ln - 1];
$is_end = $lines[$ln - 1] =~ /^\+/;
next if ($f =~ /^-/);
last if (;file && $f =~ /^\@\@/);
if ($lines[$ln - 1] =~ /^\+\s*(?:bool|tristate)\s*\"/) {
$is_start = 1;
} elsif ($lines[$ln - 1] =~ /^\+\s*(?:---)?help(?:---)?$/) {
$length = -1;
}
$f =~ s/^.//;
$f =~ s/#.*//;
$f =~ s/^\s+//;
next if ($f =~ /^$/);
if ($f =~ /^\s*config\s/) {
$is_end = 1;
last;
}
$length++;
}
if ($is_start && $is_end && $length < $min_conf_desc_length) {
WARN("CONFIG_DESCRIPTION",
}
#print "is_start<$is_start> is_end<$is_end> length<$length>\n";
}
# discourage the addition of CONFIG_EXPERIMENTAL in Kconfig.
if ($realfile =~ /Kconfig/ && e =~ /.\s*depends on\s+.*\bEXPERIMENTAL\b/) {
WARN("CONFIG_EXPERIMENTAL",
}
# discourage the use of boolean for type definition attributes of Kconfig options
if ($realfile =~ /Kconfig/ && e =~ /^\+\s*\bboolean\b/) {
WARN("CONFIG_TYPE_BOOLEAN",
}
if (($realfile =~ /Makefile.*/ || $realfile =~ /Kbuild.*/) && e =~ /\+(EXTRA_[A-Z]+FLAGS).*/)) {
my $flag = $1;
cd holbertonschool-low_level_programming/
cd 0x03-debugging/
ls
touch betty-doc.pl
emacs betty-doc.pl 
}
if (($declaration_purpose eq "")) {
print STDERR "${file}:$.: warning: missing initial short description\n";
#print STDERR $_;
++$warnings;
}
if ($identifier =~ m/^struct/) {
} elsif ($identifier =~ m/^union/) {
} elsif ($identifier =~ m/^enum/) {
} elsif ($identifier =~ m/^typedef/) {
} else {
}
if ($verbose) {
}
print STDERR "${file}:$.: warning: Cannot understand $_ on line $.",
" - I thought it was a doc line\n";
++$warnings;
$state = 0;
} elsif ($state == 2) {# look for head: lines, and include content
$newsection = $1;
$newcontents = $2;
if (($contents ne "") && ($contents ne "\n")) {
print STDERR "${file}:$.: warning: contents before sections\n";
++$warnings;
}
$in_doc_sect = 1;
$in_purpose = 0;
$contents = $newcontents;
if ($contents ne "") {
substr($contents, 0, 1) eq "\t") {
}
$section = $newsection;
if (($contents ne "") && ($contents ne "\n")) {
}
# look for doc_com + <text> + doc_end:
if ($_ =~ m'\s*\*\s*[a-zA-Z_0-9:\.]+\*/') {
}
$prototype = "";
$state = 3;
$brcount = 0;
#print STDERR "end of doc comment, looking for prototype\n";
# miguel-style comment kludge, look for blank lines after
# @parameter line to signify start of description
if ($1 eq "") {
dump_section($file, $section, xml_escape($contents));
$section = $section_default;
$contents = "";
$contents .= "\n";
} elsif ($in_purpose == 1) {
} else {
}
# i dont know - bad line?  ignore.
print STDERR "${file}:$.: warning: bad line: $_";
++$warnings;
} elsif ($state == 5) { # scanning for split parameters
$section = $1;
$contents = $2;
if ($contents ne "") {
$contents = substr($contents, 1);
$contents .= "\n";
}
$split_doc_state = 2;
if (($contents ne "") && ($contents ne "\n")) {
}
$state = 3;
$split_doc_state = 0;
f ($split_doc_st 
cd ..
git add .
git commit -m "fix betty"
git push
cd 0x03-debugging/
ls
cd ..
cd 0x02-functions_nested_loops/
emacs 0-holberton.c 
emacs holberton.h 
cd ..
cd 0x03-debugging/
ls
emacs holberton.h 
cd ..
cd 0x02
cd 0x02-functions_nested_loops/
emacs holberton.h 
ls
rm \#betty-style.pl# 
ls
touch betty-style.pl
emacs betty-style.pl 
} else {
open($FILE, '<', "$filename") ||
die "$P: $filename: open failed - $!\n";
}
if ($filename eq '-') {
$vname = 'Your patch';
} elsif ($git) {
$vname = "Commit " . substr($filename, 0, 12) . ' ("' . $git_commits{$filename} . '")';
} else {
$vname = $filename;
}
while (<$FILE>) {
chomp;
push(@rawlines, $_);
}
close($FILE);
if ($#ARGV > 0 && $quiet == 0) {
print '-' x length($vname) . "\n";
print "$vname\n";
print '-' x length($vname) . "\n";
}
$exit = 1;
}
@rawlines = ();
@lines = ();
@fixed = ();
@fixed_inserted = ();
@fixed_deleted = ();
$fixlinenr = -1;
@modifierListFile = ();
@typeListFile = ();
build_types();
}
if (}quiet) {
hash_show_words(\%use_type, "Used");
hash_show_words(\%ignore_type, "Ignored");
if ($^V lt 5.10.0) {
print << "EOM"
NOTE: perl $^V is not modern enough to detect all possible issues.
      An upgrade to at least perl v5.10.0 is suggested.
EOM

}
if ($exit) {
print << "EOM"
NOTE: If any of the errors are false positives, please report
      them to the maintainer, see CHECKPATCH in MAINTAINERS.
EOM

}
exit($exit);
sub top_of_kernel_tree {
my ($root) = @_;
my @tree_check = (
"COPYING", "CREDITS", "Kbuild", "MAINTAINERS", "Makefile",
"README", "Documentation", "arch", "include", "drivers",
"fs", "init", "ipc", "kernel", "lib", "scripts",
);
foreach my $check (@tree_check) {
if (! -e $root . '/' . $check) {
return 0;
}
return 1;
}
sub parse_email {
my ($formatted_email) = @_;
my $name = "";
my $address = "";
my $comment = "";
if ($formatted_email =~ /^(.*)<(\S+\@\S+)>(.*)$/) {
$name = $1;
$address = $2;
$comment = $3 if defined $3;
} elsif ($formatted_email =~ /^\s*<(\S+\@\S+)>(.*)$/) {
$address = $1;
$comment = $2 if defined $2;
} elsif ($formatted_email =~ /(\S+\@\S+)(.*)$/) {
$address = $1;
$comment = $2 if defined $2;
$formatted_email =~ s/$address.*$//;
$name = $formatted_email;
$name = trim($name);
$name =~ s/^\"|\"$//g;
# If there's a name left after stripping spaces and
# leading quotes, and the address doesn't have both
# leading and trailing angle brackets, the address
# is invalid. ie:
#   "joe smith joe@smith.com" bad
#   "joe smith <joe@smith.com" bad
$name = "";
$address = "";
$comment = "";
}
$name = trim($name);
$name =~ s/^\"|\"$//g;
$address = trim($address);
$address =~ s/^\<|\>$//g;
if ($name =~ /[^\w \-]/i) { ##has "must quote" chars
$name = "\"$name\"";
}
return ($name, $address, $comment);
}
sub format_email {
my ($name, $address) = @_;
my $formatted_email;
$name = trim($name);
$name =~ s/^\"|\"$//g;
ls
cd holbertonschool-low_level_programming/
ls
mkdir 0x04-more_functions_nested_loops
cd 0x04-more_functions_nested_loops/
ls
touch README.md 0-isupper.c 1-isdigit.c 2-mul.c 3-print_numbers.c 4-print_most_numbers.c 5-more_numbers.c 6-print_line.c 7-print_diagonal.c 8-print_square.c 9-fizz_buzz.c 10-print_triangle.c
ls
touch holberton.h
touch betty-style.pl
touch betty-doc.pl
ls
emacs betty-style.pl 
~ m{^.\s*\#\s*include\s*\<asm\/(.*)\.h\>}) {
my $file = "$1.h";
my $checkfile = "include/linux/$file";
if (-f "$root/$checkfile" && e $checkfile && cludes/); clude = `grep -Ec "#include\\s+<asm/$file>" $root/$checkfile`; clude > 0) {
if ($realfile =~ m{^arch/}) {
CHK("ARCH_INCLUDE_LINUX",
} else {
WARN("INCLUDE_LINUX",
}
# multi-statement macros should be enclosed in a do while loop, grab the
# first statement and ensure its the whole macro if its not enclosed
# in a known good container
if ($realfile ~ m{^.\s*\#\s*include\s*\<asm\/(.*)\.h\>}) { m@/vmlinux.lds.h$@ &&
my $ln = $linenr;
my $cnt = $realcnt;
my ($off, $dstat, $dcond, $rest);
my $ctx = '';
my $has_flow_statement = 0;
my $has_arg_concat = 0;
($dstat, $dcond, $ln, $cnt, $off) =
ctx_statement_block($linenr, $realcnt, 0);
$ctx = $dstat;
#print "dstat<$dstat> dcond<$dcond> cnt<$cnt> off<$off>\n";
#print "LINE<$lines[$ln-1]> len<" . length($lines[$ln-1]) . "\n";
$has_flow_statement = 1 if ($ctx =~ /\b(goto|return)\b/);
$has_arg_concat = 1 if ($ctx =~ /\#\#/ && $ctx ~ m{^.\s*\#\s*include\s*\<asm\/(.*)\.h\>}) { /\#\#\s*(?:__VA_ARGS__|args)\b/);
$dstat =~ s/^.\s*\#\s*define\s+$Ident(?:\([^\)]*\))?\s*//;
$dstat =~ s/$;//g;
$dstat =~ s/\\\n.//g;
$dstat =~ s/^\s*//s;
$dstat =~ s/\s*$//s;
# Flatten any parentheses and braces
while ($dstat =~ s/\([^\(\)]*\)/1/ ||  any obvious string concatentation.; g)\s*$Ident/$1/ ||
{ eric function; s = qr{; amed| E_PER_CPU| ion| t\s*=\s*| t "REST<$rest> dstat<$dstat> ctx<$ctx>\n"; e '' && t|-?$Constant),$/ &&t|-?$Constant);$/ &&stant)$/ &&stants
{ *$//; ";
t = statement_rawlines($ctx);

 = 0; $n < $cnt; $n++) {
e($linenr, $n) . "\n";
T_MACRO_USE_DO_WHILE",; ts should be enclosed in a do - while loop\n" . "$herectx");
} else {
ERROR("COMPLEX_MACRO",
      "Macros with complex values should be enclosed in parentheses\n" . "$herectx");
}
}

# check for macros with flow control, but without ## concatenation
# ## concatenation is commonly a macro that defines a function so ignore those
if ($has_flow_statement && parentheses\n" . "$herectx");
}
}

# check for macros with flow control, but without ## concatenation
# ## concatenation is commonly a macro that defines a function so ignore thosehas_arg_concat) {
my $herectx = $here . "\n";
my $cnt = statement_rawlines($ctx);
for (my $n = 0; $n < $cnt; $n++) {
$herectx .= raw_line($linenr, $n) . "\n";
}
WARN("MACRO_WITH_FLOW_CONTROL",
}
# check for line continuations outside of #defines, preprocessor #, and asm
} else {
if ($prevline ~ m{^.\s*\#\s*include\s*\<asm\/(.*)\.h\>}) { /^..*\\$/ &&
WARN("LINE_CONTINUATIONS",
}
# do {} while (0) macro tests:
# single-statement macros do not need to be enclosed in do while (0) loop,
# macro should not end with a semicolon
if ($^V && $^V ge 5.10.0 && ux.lds.h$@ && e =~ /^.\s*\#\s*define\s+$Ident(\()?/) {
my $ln = $linenr;
my $cnt = $realcnt;
my ($off, $dstat, $dcond, $rest);
my $ctx = '';
($dstat, $dcond, $ln, $cnt, $off) =
ctx_statement_block($linenr, $realcnt, 0);
$ctx = $dstat;
ls
cd holbertonschool-low_level_programming/
ls
cd 0x04-more_functions_nested_loops/
ls
rm \#betty-style.pl# 
ls
emacs betty-emacs holberton.h 
emacs holberton.h 
chmod a+x 0-isupper.c 
chmod a+x 1-isdigit.c 
chmod a+x 2-mul.c 
chmod a+x 3-
chmod a+x 3-print_numbers.c 
chmod a+x 4-print_most_numbers.c 
chmod a+x 5-more_numbers.c 
chmod a+x 6-print_line.c 
chmod a+x 7-print_diagonal.c 
chmod a+x 8-print_square.c 
chmod a+x 9-fizz_buzz.c 
chmod a+x 10-print_triangle.c 
LS
ls
chmod a+x README.md 
chmod a+x betty-doc.pl 
chmod a+x betty-style.pl 
chmod a+x holberton.h 
ls
cd ..
cd 0x03-debugging/
ls
emacs holberton.h 
cd ..
cd 0x03-debugging/
ls
cd ..
cd 0x04-more_functions_nested_loops/
ls
emacs holberton.h 
ls
cd ..
git add .
git commit -m "add 0x04"
git push
run isupper
man isupper
cd 0x04-more_functions_nested_loops/
emacs 0-isupper.c 
cd ..
git add .
git commit -m "fix 0"
git push
gcc -Wall -Werror -Wextra -pedantic 0-isupper.c
cd 0x04-more_functions_nested_loops/
gcc -Wall -Werror -Wextra -pedantic 0-isupper.c
emacs 1-isdigit.c 
emacs 0-isupper.c 
emacs 1-isdigit.c 
cd ..
git add .
git commit -m "fix 1"
git push
cd 0x04-more_functions_nested_loops/
gcc -Wall -Werror -Wextra -pedantic 1-isdigit.c
emacs 2-mul.c 
emacs 3-print_numbers.c 
cd ..
git add .
git commit -m "fix 3"
git push
cd 0x04-more_functions_nested_loops/
emacs 4-print_most_numbers.c 
emacs 5-more_numbers.c 
emacs 6-print_line.c 
cd ..
git add .
git commit -m "fix 6"
git push
cd 0x04-more_functions_nested_loops/
emacs README.md 
cd ..
git add .
git commit -m "fix README"
git push
cd 0x04-more_functions_nested_loops/
emacs 6-print_line.c 
emacs 7-print_diagonal.c
cd ..
git add .
git commit -m "fix 8"
git push
cd 0x04-more_functions_nested_loops/
ls
emacs 10-print_triangle.c 
cd ..
git add .
git commit -m "fix 10"
git push
cd 0x04-more_functions_nested_loops/
emacs 10-print_triangle.c 
cd ..
git add .
git commit -m "fix 10"
git push
cd 0x04-more_functions_nested_loops/
ls
rm holberton.h~
ls
emacs 8-print_square.c 
cd ..
git add .
git commit -m "fix 8"
git push
cd 0x04-more_functions_nested_loops/
emacs 9-fizz_buzz.c 
cd ..
git add .
git commit -m "fix 8"
git push
cd 0x04-more_functions_nested_loops/
gcc -Wall -Werror -Wextra -pedantic 8-print_square.c
ls
emacs 8-print_square.c 
emacs 7-print_diagonal.c 
cd ..
git add .
git commit -m "fix 7"
git push
cd 0x04-more_functions_nested_loops/
emacs 7-print_diagonal.c 
cd ..
git add .
git commit -m "fix 7"
git push
cd 0x04-more_functions_nested_loops/
ls
emacs 8-print_square.c 
emacs 10-print_triangle.c 
emacs 7-print_diagonal.c 
emacs 9-fizz_buzz.c 
cd ..
git add .
git commit -m "fix 9"
git push
cd 0x04-more_functions_nested_loops/
emacs 5-more_numbers.c 
emacs 10-print_triangle.c 
cd ..
git add .
git commit -m "fix 10"
git push
cd 0x04-more_functions_nested_loops/
emacs 8-print_square.c 
cd ..
git add .
git commit -m "fix 8"
git push
cd 0x04-more_functions_nested_loops/
emacs 9-fizz_buzz.c 
ls
cd holbertonschool-low_level_programming/
ls
mkdir 0x05-pointers_arrays_strings
cd 0x05-pointers_arrays_strings/
ls
touch README.md
emacs README.md 
touch 0-reset_to_98.c 1-swap.c 2-strlen.c 3-puts.c 4-print_rev.c 5-rev_string.c 6-puts.c 7-puts_half.c 8-print_array.c 9-strcpy.c
ls
rm README.md~
ls
emacs 0-reset_to_98.c 
emacs 1-swap.c 
emacs 2-strlen.c 
man strlen
emacs 2-strlen.c 
emacs 3-puts.c 
man puts
emacs 3-puts.c 
emacs 4-print_rev.c 
emacs 5-rev_string.c
emacs 6-puts.c 
emacs 8-print_array.c 
cd ..
git add .
git commit -m "add 0x05"
git push
ls
cd holbertonschool-low_level_programming/
ls
mkdir 0x06-pointers_arrays_strings
ls
cd 0x06-pointers_arrays_strings/
ls
touch README.md
ls
touch 0-strcat.c 1-strncat.c
ls
touch 2-strncpy.c 3-strcmp.c 4-rev_array.c 5-string_toupper.c 6-cap_string.c 7-leet.c 8-rot13.c
ls
chmod u+x README.md 
ls
chmod u+x 0-strcat.c 
chmod u+x 1-strncat.c 
chmod u+x 2-strncpy.c 
chmod u+x 3-strcmp.c 
chmod u+x 4-rev_array.c 
chmod u+x 5-string_toupper.c 
chmod u+x 6-cap_string.c 
chmod u+x 7-leet.c 
chmod u+x 8-rot13.c 
ls
emacs README.md 
man strcat
emacs 0-strcat.c 
emacs 1-strncat.c 
emacs 0-strcat.c 
emacs 1-strncat.c 
emacs 0-strcat.c 
emacs 1-strncat.c 
man strncat
emacs 1-strncat.c 
gcc -Wall -pedantic -Werror -Wextra 1-main.c 1-strncat.c -o 1-strncat
gcc -Wall -pedantic -Werror -Wextra 1-strncat.c -o 1-strncat
emacs 1-strncat.c 
emacs 2-strncpy.c 
man strncpy
manstrncat
man strncat
emacs 1-strncat.c
man strcat
emacs 0-strcat.c
man strncpy
emacs 2-strncpy.c
man strcmp
emacs 2-strncpy.c
emacs 3-strcmp.c 
man strcmp
man strncmp
man bcmp
man memcmp
emacs 7-leet.c 
man strncmp
man strcpy
emacs 3-strcmp.c 
man strcmp
man strncmp
emacs 3-strcmp.c 
emacs 4-rev_array.c 
emacs 3-strcmp.c
emacs 2-strncpy.c
emacs 3-strcmp.c
man strcmp
emacs 3-strcmp.c
cd
ls
cd holbertonschool-low_level_programming/
ls
cd 0x00-hello_world/
emacs 0-preprocessor 
cd ..
git add .
git commit -m "update with current terminal"
git push
cd 0x00-hello_world/
ls
cd
ls
cd repo/
ls
sudo ./install.sh
sudo apt-get ./install.sh
sudo apt-get update
cd
cd /bin/
ls
cd Betty/
ls
cd
cd holbertonschool-low_level_programming/
ls
cd 0x00-hello_world/
betty 0-preprocessor 
betty 1-compiler 
cd ..
cd 0x06-pointers_arrays_strings/
betty 0-strcat.c
cd ..
cd 0x00-hello_world/
betty 5-printf.c 
betty 0-preprocessor 
emacs 1-compiler 
emacs 2-assembler 
emacs 3-name 
emacs 4-puts.c 
emacs 5-printf.c 
git add 5-printf.c 
git commit -m "fix 5"
git push
emacs 5-printf.c 
git add 5-printf.c 
git commit -m "fix 5"
git push
betty 5-printf.c 
emacs 5-printf.c 
git add 5-printf.c 
git commit -m "fix 5"
git push
gcc -Wall 5-printf.c 
emacs 5-printf.c 
gcc -Wall 5-printf.c 
emacs 5-printf.c 
gcc -Wall 5-printf.c 
emacs 5-printf.c 
gcc -Wall 5-printf.c 
emacs 5-printf.c 
gcc -Wall 5-printf.c 
git add 5-printf.c 
git commit -m "fix 5"
git push
ls
cd holbertonschool-low_level_programming/
ls
cd 0x06-pointers_arrays_strings/
emacs 6-cap_string.c 
ls
man gcc
man malloc
cd ..
ls
cd repo/
ls
cd ..
cd 0x04-more_functions_nested_loops/
ls
cp holberton.h 
cp holberton.h .
cp holberton.h ..
cd ..
ls
mv holberton.h 0x06-pointers_arrays_strings/
ls
cd 0x06-pointers_arrays_strings/
ls
git add .
git commit -m "fix header"
git push
ls
emacs holberton.h 
cd ..
cd 0x00-hello_world/
emacs 1-compiler 
ls
emacs main.c 
emacs 1-compiler 
man gcc
emacs 1-compiler 
git add 1-compiler 
git commit -m "fix 1"
git push
emacs 1-compiler 
betty 1-compiler 
git add 1-compiler 
git commit -m "fix 1"
git push
emacs 1-compiler 
git add 1-compiler 
git commit -m "fix 1"
git push
emacs 1-compiler 
git add 1-compiler 
git commit -m "fix 1"
git push
emacs 1-compiler 
git add 1-compiler 
git commit -m "fix 1"
git push
emacs 1-compiler 
git add 1-compiler 
git commit -m "fix 1"
git push
emacs 1-compiler 
git add 1-compiler 
git commit -m "fix 1"
git push
emacs 1-compiler 
man gcc
emacs 1-compiler 
git add 1-compiler 
git commit -m "fix 1"
git push
emacs 1-compiler 
emacs 2-assembler 
git add 2-assembler 
git commit -m "fix 2"
git push
emacs 3-name 
git add 3-name 
git commit -m "fix 3"
git push
emacs 3-name 
git add 3-name 
git commit -m "fix 3"
git push
emacs 4-puts.c 
git add 4-puts.c 
git commit -m "fix 4"
git push
emacs 4-puts.c 
emacs 5-printf.c 
gcc -Wall 5-printf.c 
emacs 5-printf.c 
gcc -Wall 5-printf.c 
gcc -Wall main.c 5-printf.c 
emacs 5-printf.c 
git add 5-printf.c 
git commit -m "fix 5"
git push
betty 5-printf.c 
emacs 5-printf.c 
betty 5-printf.c 
emacs 5-printf.c 
git add 5-printf.c 
git commit -m "fix 5"
git push
betty 5-printf.c 
emacs 5-printf.c 
betty 5-printf.c 
emacs 5-printf.c 
betty 5-printf.c 
emacs 5-printf.c 
betty 5-printf.c 
emacs 5-printf.c 
betty 5-printf.c 
emacs 5-printf.c 
betty 5-printf.c 
emacs 5-printf.c 
betty 5-printf.c 
git add 5-printf.c 
git commit -m "fix 5"
git push
emacs 5-printf.c 
git add 5-printf.c 
git commit -m "fix 5"
git push
emacs 4-puts.c 
git add 4-puts.c 
git commit -m "fix 4"
git push
emacs 4-puts.c 
git add 4-puts.c 
git commit -m "fix 4"
git push
emacs 4-puts.c 
git add 4-puts.c 
git commit -m "fix 4"
git push
emacs 5-printf.c 
git add 5-printf.c 
git commit -m "fix 5"
git push
emacs 5-printf.c 
git add 5-printf.c 
git commit -m "fix 5"
git push
gcc -Wall 5-printf.c 
emacs 5-printf.c 
git add 5-printf.c 
git commit -m "fix 5"
git push
emacs 6-size.c 
gcc 6-size.c -m32 -o size32 2> /tmp/32
gcc 6-size.c -m64 -o size64 2> /tmp/64
emacs 6-size.c 
git add 6-size.c 
git commit -m "fix 6"
git push
cd ..
ls
mkdir 0x07-pointers_arrays_strings
cd 0x07-pointers_arrays_strings/
ls
touch README.md
emacs README.md 
touch 0-memset.c 1-memcpy.c 2-strchr.c 3-strspn.c 4-strpbrk.c 5-strstr.c 7-print_chessboard.c 8-print_diagsums.c 9-set_string.c
ls
rm README.md~
ls
git add .
git commit -m "add 07"
git push
emacs 0-memset.c 
man memset
emacs 0-memset.c 
gcc -Wall -pedantic -Werror -Wextra 0-main.c 0-memset.c -o 0-memset
touch 0-main.c
emacs 0-main.c 
gcc -Wall -pedantic -Werror -Wextra 0-main.c 0-memset.c -o 0-memset
cd ..
cd 0x06-pointers_arrays_strings/
ls
cp holberton.h ..
ls
cd ..
ls
mv holberton.h 0x07-pointers_arrays_strings/
ls
cd 0x07-pointers_arrays_strings/
ls
gcc -Wall -pedantic -Werror -Wextra 0-main.c 0-memset.c -o 0-memset
rm 0-main.c~
ls
emacs 0-m
emacs 0-memset.c 
man memset
touch 1-main.c
emacs 1-main.c 
touch 2-main.c
emacs 2-main.c 
touch 3-main.c
emacs 3-main.c 
touch 4-main.c
emacs 4-main.c 
touch 5-main.c
emacs 5-main.c 
touch 7-main.c
emacs 7-main.c 
touch 8-main.c
emacs 8-main.c 
touch 9-main.c
emacs 9-main.c 
man argv
man argc
emacs 5-strstr.c 
emacs 4-strpbrk.c 
emacs 3-main.c
emacs 4-main.c
emacs 4-strpbrk.c 
emacs 5-strstr.c 
rm 5-main.c~
emacs 7-print_chessboard.c 
emacs 7-main.c
emacs 8-print_diagsums.c 
emacs 8-main.c
emacs 9-set_string.c 
emacs 9-main.c
git add .
git commit -m "fix 07"
git push
gcc -Wall -pedantic -Werror -Wextra 5-main.c 5-strstr.c -o 5-strstr
emacs 5-main.c 
man strpbrk
man strspn
man strpbrk
man strstr
ls
rm 1-main.c~ 2-main.c~ 3-main.c~ 4-main.c~ 7-main.c~ 8-main.c~ 9-main.c~
ls
cd ..
cd 0x00-hello_world/
ls
emacs \#1-compiler# 
rm \#1-compiler# 
ls
emacs 4-puts.c 
git add 4-puts.c 
git commit -m "fix 4"
git push
gcc 4-puts.c && ./a.out
echo $?
git add 4-puts.c 
git commit -m "fix 4"
git commit -a -m "sync with remote"
git push
emacs 4-puts.c 
git add 4-puts.c 
git commit -m "fix 4"
git push
emacs 5-printf.c 
git add 5-printf.c 
git commit -m "add 5"
git push
emacs 5-printf.c 
gcc -Wall 5-printf.c 
gcc -Wall 4-puts.c 
emacs 5-printf.c 
git add 5-printf.c 
git commit -m "fix 5"
git push
emacs 4-puts.c 
git add 4-puts.c 
git commit -m "fix 4"
git push
betty 5-printf.c 
betty 4-puts.c 
emacs 4-puts.c 
betty 4-puts.c 
git add 4-puts.c 
git commit -m "fix 4"
git push
emacs 5-printf.c 
emacs 4-puts.c 
betty 4-puts.c 
betty 5-printf.c 
emacs 5-printf.c 
betty 5-printf.c 
emacs 5-printf.c 
betty 5-printf.c 
emacs 5-printf.c 
betty 5-printf.c 
emacs 5-printf.c 
betty 5-printf.c 
emacs 5-printf.c 
betty 5-printf.c 
emacs 5-printf.c 
betty 5-printf.c 
emacs 5-printf.c 
betty 5-printf.c 
emacs 5-printf.c 
betty 5-printf.c 
git add 5-printf.c 
git commit -m "fix 5"
git push
emacs 5-printf.c 
gcc -Wall 5-printf.c 
emacs 5-printf.c 
gcc -Wall 5-printf.c 
emacs 5-printf.c 
gcc -Wall 5-printf.c 
emacs 5-printf.c 
gcc -Wall 5-printf.c 
emacs 5-printf.c 
gcc -Wall 5-printf.c 
git add 5-printf.c 
git commit -m "fix 5"
git push
emacs 4-puts.c 
git add 4-puts.c 
git commit -m "fix 4"
git push
emacs 4-puts.c 
gcc -Wall 5-printf.c 
gcc -Wall 4-puts.c 
ls
cd holbertonschool-low_level_programming/
ls
mkdir 0x08-recursion
cd 0x08-recursion/
touch 0-puts_recursion.c 1-print_rev_recursion.c 2-strlen_recursion.c 3-factorial.c 4-pow_recursion.c 5-sqrt_recursion.c 6-is_prime_number.c 7-is_palindrome.c README.md
ls
emacs README.md 
ls
rm README.md~
ls
touch 0-main.c 1-main.c 2-main.c 3-main.c 4-main.c 5-main.c 6-main.c 7-main.c 
ls
emacs 0-main.c 
emacs 1-main.c 
emacs 2-main.c 
emacs 3-main.c 
emacs 4-main.c 
emacs 5-main.c 
emacs 6-main.c 
emacs 7-main.c 
cd ..
git add 0x08-recursion/
git commit -m "add 08"
git push
cd 0x08-recursion/
ls
rm 0-main.c~ 1-main.c~ 2-main.c~ 3-main.c~ 4-main.c~ 5-main.c~ 6-main.c~ 7-main.c~
ls
man puts
emacs 0-puts_recursion.c 
emacs 1-print_rev_recursion.c 
emacs 2-strlen_recursion.c 
emacs 3-factorial.c 
git add 3-factorial.c 
git commit -m "fix 3"
git push
emacs 4-pow_recursion.c 
man pow
gcc -Wall -pedantic -Werror -Wextra _putchar.c 0-main.c 0-puts_recursion.c -o 0-puts_recursion
man pow
emacs 0-puts_recursion.c 
gcc -Wall -pedantic -Werror -Wextra _putchar.c 0-main.c 0-puts_recursion.c -o 0-puts_recursion
cd ..
cd 0x07-pointers_arrays_strings/
ls
emacs holberton.h 
cp holberton.h .
cp holberton.h ..
ls
cd ..
ls
mv holberton.h 0x08-recursion/
ls
cd 0x08-recursion/
ls
gcc -Wall -pedantic -Werror -Wextra _putchar.c 0-main.c 0-puts_recursion.c -o 0-puts_recursion
emacs 1-print_rev_recursion.c 
emacs 2-strlen_recursion.c 
emacs 3-factorial.c 
emacs 4-pow_recursion.c 
emacs 5-sqrt_recursion.c 
man sqrt
emacs 5-sqrt_recursion.c 
git add .
git commit -a -m "sync wth remote"
git push
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 5-sqrt_recursion.c 
betty 5-sqrt_recursion.c 
emacs 6-is_prime_number.c 
emacs 7-is_palindrome.c 
ls
touch 100-wildcmp.c
touch 100-main.c
emacs 100-main.c 
ls
rm 100-main.c~
ls
git add .
git commit -m "fix 8"
git commit -m "fix 100"
git push
cd ..
cd 0x04-more_functions_nested_loops/
ls
emacs holberton.h 
cd ..
cd 0x05-pointers_arrays_strings/
ls
cd ..
cd 0x06-pointers_arrays_strings/
ls
emacs holberton.h 
cd ..
cd 0x07-pointers_arrays_strings/
ls
emacs holberton.h 
ls
cd holbertonschool-low_level_programming/
ls
mkdir 0x09-static_libraries
ls
cd 0x09-static_libraries/
touch libholberton.a holberton.h create_static_lib.sh
ls
touch README.md
emacs README.md 
ls
rm README.md~
ls
emacs libholberton.a
cd ..
git add 0x09-static_libraries/
git commit -m "add 09"
git push
cd 0x09-static_libraries/
ls
rm libholberton.a~
ls
touch main.c
emacs main.c 
ls
rm main.c~
ls
gcc main.c -L. -lholberton -o quote
./quote
ar -t libholberton.a 
nm libholberton.a 
ls *.c
gcc main.c -L. -lholberton -o quote
ls *.a
ar -t liball.a
man ranlib
cd ..
ls
mkdir 0x0A-argc_argv
cd 0x0A-argc_argv/
ls
touch README.md 0-whatsmyname.c 1-args.c 2-args.c 3-mul.c 4-add.c
ls
emacs README.md 
cd ..
git add 0x0A-argc_argv/
git commit -m "add 0A"
git push
LS
ls
cd 0x0A-argc_argv/
ls
rm README.md~
ls
ls -a
cd ..
cd 0x00-hello_world/
emacs 4-puts.c 
emacs 5-printf.c 
betty 4-puts.c 
emacs 5-printf.c 
betty 4-puts.c 
emacs 4-puts.c 
betty 4-puts.c 
emacs 4-puts.c 
emacs 5-printf.c 
betty 5-printf.c 
betty 4-puts.c 
git add 4-puts.c 5-printf.c 
git commit -m "fix 4 and 5"
git push
emacs 6-size.c 
gcc 6-size.c -m32 -o size32 2> /tmp/32
gcc 6-size.c -m64 -o size64 2> /tmp/64
ls
touch 100-intel
touch 101-quote.c
emacs 101-quote.c 
git add 101-quote.c
git commit -m "add 101"
git push
emacs 101-quote.c 
git add 101-quote.c
git commit -m "fix 101"
git push
ls
cd holbertonschool-low_level_programming/
ls
0x0A-argc_argv/
cd 0x0A-argc_argv/
ls
emacs 1-args.c 
git add 1-args.c 
git commit -m "fix 1"
git push
cd ..
cd 0x04-more_functions_nested_loops/
emacs 9-fizz_buzz.c 
git add 9-fizz_buzz.c 
git commit -m "fix 9"
git push
ls
cd holbertonschool-low_level_programming/
ls
mkdir 0x0B-malloc_free
cd 0x0B-malloc_free/
touch README.md 0-create_array.c 1-strdup.c 2-str_concat.c 3-alloc_grid.c 4-free_grid.c 5-argstostr.c
ls
emacs README.md 
cd ..
ls
git add 0x0B-malloc_free/
git commit -m "add 0x0B"
git push
cd 0x01-variables_if_else_while/
emacs 0-positive_or_negative.c 
git add 0-positive_or_negative.c 
git commit -m "fix 0"
git push
emacs 0-positive_or_negative.c 
git add 0-positive_or_negative.c 
git commit -m "fix 0"
git push
emacs 0-positive_or_negative.c 
git add 0-positive_or_negative.c 
git commit -m "fix 0"
git push
betty 0-positive_or_negative.c 
emacs 0-positive_or_negative.c 
git add 0-positive_or_negative.c 
git commit -m "fix 0"
git push
betty 0-positive_or_negative.c 
emacs 0-positive_or_negative.c 
betty 0-positive_or_negative.c 
emacs 0-positive_or_negative.c 
betty 0-positive_or_negative.c 
emacs 0-positive_or_negative.c 
betty 0-positive_or_negative.c 
emacs 0-positive_or_negative.c 
betty 0-positive_or_negative.c 
emacs 0-positive_or_negative.c 
git add 0-positive_or_negative.c 
git commit -m "fix 0"
git push
emacs 1-last_digit.c 
git add 1-last_digit.c 
git commit -m "fix 1"
git push
emacs 2-print_alphabet.c 
git add 2-print_alphabet.c 
git commit -m "fix 2"
git push
emacs 3-print_alphabets.c 
git add 3-print_alphabets.c 
git commit -m "fix 3"
git push
betty 3-print_alphabets.c 
emacs 3-print_alphabets.c 
betty 3-print_alphabets.c 
emacs 3-print_alphabets.c 
betty 3-print_alphabets.c 
emacs 3-print_alphabets.c 
betty 3-print_alphabets.c 
emacs 3-print_alphabets.c 
betty 3-print_alphabets.c 
emacs 3-print_alphabets.c 
betty 3-print_alphabets.c 
emacs 3-print_alphabets.c 
betty 3-print_alphabets.c 
emacs 3-print_alphabets.c 
betty 3-print_alphabets.c 
emacs 3-print_alphabets.c 
betty 3-print_alphabets.c 
emacs 3-print_alphabets.c 
betty 3-print_alphabets.c 
emacs 3-print_alphabets.c 
betty 3-print_alphabets.c 
emacs 3-print_alphabets.c 
betty 3-print_alphabets.c 
emacs 3-print_alphabets.c 
betty 3-print_alphabets.c 
emacs 3-print_alphabets.c 
betty 3-print_alphabets.c 
emacs 3-print_alphabets.c 
git add 3-print_alphabets.c 
git commit -m "fix 3"
git push
cd ..
ls
cd 0x0B-malloc_free/
emacs 0-create_array.c 
ls
rm README.md~
ls
touch holberton.h
emacs holberton.h 
emacs 0-create_array.c 
emacs holberton.h 
git add holberton.h
git commit -m "fix header"
git push
emacs 0-create_array.c 
git add 0-create_array.c 
git commit -m "fix 0"
git push
emacs holberton.h
git add holberton.h
git commit -m "fix header"
git push
man strdup
emacs 1-strdup.c 
touch 0-main.c
emacs 0-main.c 
gcc -Wall -pedantic -Werror -Wextra 0-main.c 0-create_array.c -o a
touch 1-main.c
emacs 1-main.c 
gcc -Wall -pedantic -Werror -Wextra 1-main.c 1-strdup.c -o s
touch 2-main.c
emacs 2-main.c 
touch 3-main.c
emacs 3-main.c 
touch 4-main.c
emacs 4-main.c 
touch 5-main.c
emacs 5-main.c 
git add 0-main.c 1-main.c 2-main.c 3-main.c 4-main.c 5-main.c
git commit -m "fix main"
git push
man strdup
man malloc
gcc

sudo apt-get install gcc
emacs 0-create_array.c 
emacs 2-str_concat.c 
git add 2-str_concat.c 
git commit -m "fix 2"
git push
emacs 2-str_concat.c 
cd ..
cd 0x01-variables_if_else_while/
emacs 2-print_alphabet.c 
git add 2-print_alphabet.c 
git commit -m "fix 2"
git push
gcc -Wall -pedantic -Werror -Wextra 2-print_alphabet.c -o 2-print_alphabet
emacs 2-print_alphabet.c 
gcc -Wall -pedantic -Werror -Wextra 2-print_alphabet.c -o 2-print_alphabet
emacs 2-print_alphabet.c 
gcc -Wall -pedantic -Werror -Wextra 2-print_alphabet.c -o 2-print_alphabet
emacs 3-print_alphabets.c 
gcc -Wall -pedantic -Werror -Wextra 3-print_alphabets.c -o 3-print_alphabets
emacs 3-print_alphabets.c 
gcc -Wall -pedantic -Werror -Wextra 3-print_alphabets.c -o 3-print_alphabets
ls
cd holbertonschool-low_level_programming/
ls
mkdir 0x0C-more_malloc_free
ls
cd 0x0C-more_malloc_free/
touch README.md 0-malloc_checked.c 1-string_nconcat.c 2-calloc.c 3-array_range.c
ls
emacs README.md 
cd ..
ls
cd 0x0C-more_malloc_free/
ls
rm README.md~
ls
cd ..
git add 0x0C-more_malloc_free/
git commit -m "add 0C"
git push
cd 0x0C-more_malloc_free/
ls
touch 0-main.c 1-main.c 2-main.c 3-main.c 
emacs 0-ma
ls
emacs 0-main.c 
emacs 1-main.c 
emacs 2-main.c 
emacs 3-main.c 
git add 0-main.c 1-main.c 2-main.c 3-main.c
git commit -m "add main"
git push
touch holberton.h
emacs holberton.h 
git add holberton.h
git commit -m "add header"
git push
emacs 0-malloc_checked.c 
man exit
emacs 0-malloc_checked.c 
emacs holberton.h
git add 0-malloc_checked.c 
git commit -m "fix 0"
git add holberton.h
git commit -m "fix header"
git push
KathleenRMcK
git push
cd holbertonschool-low_level_programming/
cd 0x0C-more_malloc_free/
gcc -Wall -pedantic -Werror -Wextra 1-main.c 1-string_nconcat.c -o b
emacs 0-malloc_checked.c 
emacs 1-string_nconcat.c 
gcc -Wall -pedantic -Werror -Wextra 1-main.c 1-string_nconcat.c -o b
emacs 1-string_nconcat.c 
betty 1-string_nconcat.c 
emacs 1-string_nconcat.c 
betty 1-string_nconcat.c 
emacs 1-string_nconcat.c 
betty 1-string_nconcat.c 
emacs 1-string_nconcat.c 
betty 1-string_nconcat.c 
emacs 1-string_nconcat.c 
betty 1-string_nconcat.c 
emacs 1-string_nconcat.c 
betty 1-string_nconcat.c 
emacs 1-string_nconcat.c 
betty 1-string_nconcat.c 
gcc -Wall -pedantic -Werror -Wextra 1-main.c 1-string_nconcat.c -o b
emacs 1-string_nconcat.c 
gcc -Wall -pedantic -Werror -Wextra 1-main.c 1-string_nconcat.c -o b
emacs 1-string_nconcat.c 
gcc -Wall -pedantic -Werror -Wextra 1-main.c 1-string_nconcat.c -o b
emacs 1-string_nconcat.c 
emacs 2-calloc.c 
emacs 3-array_range.c 
ls
emacs 0-malloc_checked.c 
git add .
git commit -m "update 0C"
git push
betty 0-malloc_checked.c 
emacs 0-malloc_checked.c 
betty 0-malloc_checked.c 
emacs 0-malloc_checked.c 
betty 0-malloc_checked.c 
emacs 0-malloc_checked.c 
betty 0-malloc_checked.c 
emacs 0-malloc_checked.c 
betty 0-malloc_checked.c 
emacs 0-malloc_checked.c 
betty 0-malloc_checked.c 
emacs 0-malloc_checked.c 
betty 0-malloc_checked.c 
emacs 0-malloc_checked.c 
betty 1-string_nconcat.c 
emacs 1-string_nconcat.c 
betty 1-string_nconcat.c 
emacs 1-string_nconcat.c 
betty 1-string_nconcat.c 
emacs 1-string_nconcat.c 
betty 1-string_nconcat.c 
emacs 2-calloc.c 
betty 1-string_nconcat.c 
emacs 1-string_nconcat.c 
emacs 0-malloc_checked.c 
emacs 2-calloc.c 
git add .
git commit -m "update 0C"
git push
emacs 2-calloc.c 
betty 2-calloc.c 
emacs 2-calloc.c 
betty 2-calloc.c 
emacs 2-calloc.c 
betty 2-calloc.c 
emacs 2-calloc.c 
betty 2-calloc.c 
git add .
git commit -m "update 0C"
git push
cd ..
ls
cd 0x00-hello_world/
ls
emacs 4-puts.c 
git add 4-puts.c 
git commit -m "fix 4"
git push
emacs 5-printf.c 
git add 5-printf.c 
git commit -m "fix 5"
git push
emacs 4-puts.c 
emacs 5-printf.c 
git add 4-puts.c 5-printf.c 
git commit -m "fix betty"
git push
emacs 5-printf.c 
emacs 4-puts.c 
emacs 5-printf.c 
emacs 4-puts.c 
emacs 5-printf.c 
emacs 4-puts.c 
git add 4-puts.c 
git commit -m "fix 4"
git push
gcc 4-puts.c 
./a
./c
cd ..
cd 0x01-variables_if_else_while/
emacs 2-print_alphabet.c 
cd holbertonschool-low_level_programming/
ls
mkdir 0x0F-function_pointers
cd 0x0F-function_pointers/
touch README.md 0-print_name.c 0-main.c 1-main.c 1-array_iterator.c 2-main.c 2-int_index.c 3-main.c 3-op_functions.c 3-get_op_func.c 3-calc.h
ls
emacs 0-print_name.c 
emacs 0-main.c 
emacs 1-array_iterator.c 
emacs 1-main.c 
emacs 2-int_index.c 
emacs 2-main.c 
emacs 3-calc.h 
emacs 3-op_functions.c 
emacs 3-get_op_func.c 
emacs README.md 
cd ..
git add 0x0F-function_pointers/
git commit -m "add 0F"
git push
cd 0x0F-function_pointers/
ls
rm 0-main.c~ 0-print_name.c~ 1-array_iterator.c~ 1-main.c~ 2-int_index.c~ 2-main.c~ 3-calc.h~ 3-get_op_func.c~ 3-op_functions.c~ README.md~
git add .
git add -A .
git commit -m "fix 0F"
git push
ls
touch function_pointers.h
emacs function_pointers.h 
cd holbertonschool-low_level_programming/
ls
cd 0x0F-function_pointers/
ls
emacs function_pointers.h 
git add function_pointers.h
git commit -m "fix header"
git push
ls
rm function_pointers.h~
git add -a .
git add -A .
git commit -m "remove extra files"
git push
ls
emacs 0-print_name.c 
git add 0-print_name.c 
git commit -m "fix 0"
git push
ls
emacs 0-print_name.c 
ls
man rm
rm -f -r holbertonschool-low_level_programming/
ls
rm -f -r holbertonschool-zero_day/
ls
rm -f -r holberton-system_engineering-devops/
rm -f -r repo/
ls
