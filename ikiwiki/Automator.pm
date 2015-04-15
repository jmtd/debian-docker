#!/usr/bin/perl
# Ikiwiki setup automator.

package IkiWiki::Setup::Automator;

use warnings;
use strict;
use IkiWiki;
use IkiWiki::UserInfo;
use Term::ReadLine;
use File::Path;
use Encode;

sub ask ($$) {
	my ($question, $default)=@_;

	my $r=Term::ReadLine->new("ikiwiki");
	$r->ornaments("md,me");
	$r->readline(encode_utf8($question)." ", $default);
}

sub prettydir ($) {
	my $dir=shift;
	$dir=~s/^\Q$ENV{HOME}\E\//~\//;
	return $dir;
}

sub sanitize_wikiname ($) {
	my $wikiname=shift;

	# Sanitize this to avoid problimatic directory names.
	$wikiname=~s/[^-A-Za-z0-9_]//g;
	if (! length $wikiname) {
		error gettext("you must enter a wikiname (that contains alphanumerics)");
	}
	return $wikiname;
}

sub import (@) {
	my $this=shift;
	$config{setuptype}='Yaml';
	IkiWiki::Setup::merge({@_});

	if (! $config{force_overwrite}) {
		# Avoid overwriting any existing files.
		foreach my $key (qw{srcdir destdir repository dumpsetup}) {
			next unless exists $config{$key};
			my $add="";
			my $dir=IkiWiki::dirname($config{$key})."/";
			my $base=IkiWiki::basename($config{$key});
			while (-e $dir.$add.$base) {
				$add=1 if ! $add;
				$add++;
			}
			$config{$key}=$dir.$add.$base;
		}
	}
	
	# Set up wrapper
	if ($config{rcs}) {
		if ($config{rcs} eq 'git') {
			$config{git_wrapper}=$config{repository}."/hooks/post-update";
		}
		elsif ($config{rcs} eq 'svn') {
			$config{svn_wrapper}=$config{repository}."/hooks/post-commit";
		}
		elsif ($config{rcs} eq 'monotone') {
			$config{mtn_wrapper}=$config{srcdir}."_MTN/ikiwiki-netsync-hook";
		}
		elsif ($config{rcs} eq 'darcs') {
			$config{darcs_wrapper}=$config{repository}."/_darcs/ikiwiki-wrapper";
		}
		elsif ($config{rcs} eq 'bzr') {
			# TODO
			print STDERR "warning: do not know how to set up the bzr_wrapper hook!\n";
		}
		elsif ($config{rcs} eq 'mercurial') {
			# TODO
			print STDERR "warning: do not know how to set up the mercurial_wrapper hook!\n";
		}
		elsif ($config{rcs} eq 'tla') {
			# TODO
			print STDERR "warning: do not know how to set up the tla_wrapper hook!\n";
		}
		elsif ($config{rcs} eq 'cvs') {
			$config{cvs_wrapper}=$config{repository}."/CVSROOT/post-commit";
		}
		else {
			error sprintf(gettext("unsupported revision control system %s"),
			       	$config{rcs});
		}
	}

	IkiWiki::checkconfig();

	print "\n\nSetting up $config{wikiname} ...\n";

	# Set up the srcdir.
	mkpath($config{srcdir}) || die "mkdir $config{srcdir}: $!";
	# Copy in example wiki.
	if (exists $config{example}) {
		# cp -R is POSIX
		# Another reason not to use -a is so that pages such as blog
		# posts will not have old creation dates on this new wiki.
		system("cp -R $IkiWiki::installdir/share/ikiwiki/examples/$config{example}/* $config{srcdir}");
		delete $config{example};
	}

	# Set up the repository.
	delete $config{repository} if ! $config{rcs} || $config{rcs}=~/bzr|mercurial/;
	if ($config{rcs}) {
		my @params=($config{rcs}, $config{srcdir});
		push @params, $config{repository} if exists $config{repository};
		if (system("ikiwiki-makerepo", @params) != 0) {
			error gettext("failed to set up the repository with ikiwiki-makerepo");
		}
	}

	# Make sure that all the listed plugins can load
	# and checkconfig is ok. If a plugin fails to work,
	# remove it from the configuration and keep on truckin'.
	my %bakconfig=%config; # checkconfig can modify %config so back up
	if (! eval { IkiWiki::loadplugins(); IkiWiki::checkconfig() }) {
		foreach my $plugin (@{$config{default_plugins}}, @{$bakconfig{add_plugins}}) {
			eval {
				# delete all hooks so that only this plugins's
				# checkconfig will be run
				%IkiWiki::hooks=();
				IkiWiki::loadplugin($plugin);
				IkiWiki::run_hooks(checkconfig => sub { shift->() });
			};
			if ($@) {
				my $err=$@;
				print STDERR sprintf(gettext("** Disabling plugin %s, since it is failing with this message:"),
					$plugin)."\n";
				print STDERR "$err\n";
				push @{$bakconfig{disable_plugins}}, $plugin;
			}
		}
	}
	%config=%bakconfig;

	# Generate setup file.
	require IkiWiki::Setup;
	IkiWiki::Setup::dump($config{dumpsetup});

	# Build the wiki, but w/o wrappers, so it's not live yet.
	mkpath($config{destdir}) || die "mkdir $config{destdir}: $!";
	if (system("ikiwiki", "--refresh", "--setup", $config{dumpsetup}) != 0) {
		die "ikiwiki --refresh --setup $config{dumpsetup} failed";
	}

	# Create admin user(s).
	foreach my $admin (@{$config{adminuser}}) {
		next if defined IkiWiki::openiduser($admin);
		
		# Prompt for password w/o echo.
		my ($password, $password2);
		system('stty -echo 2>/dev/null');
		local $|=1;
		print "\n\nCreating wiki admin $admin ...\n";
		for (;;) {
			print "Choose a password: ";
			chomp($password=<STDIN>);
			print "\n";
			print "Confirm password: ";
			chomp($password2=<STDIN>);

			last if $password2 eq $password;

			print "Password mismatch.\n\n";
		}
		print "\n\n\n";
		system('stty sane 2>/dev/null');

		if (IkiWiki::userinfo_setall($admin, { regdate => time }) &&
		    IkiWiki::Plugin::passwordauth::setpassword($admin, $password)) {
			IkiWiki::userinfo_set($admin, "email", $config{adminemail}) if defined $config{adminemail};
		}
		else {
			error("problem setting up $admin user");
		}
	}
	
	# Add wrappers, make live.
	if (system("ikiwiki", "--wrappers", "--setup", $config{dumpsetup}) != 0) {
		die "ikiwiki --wrappers --setup $config{dumpsetup} failed";
	}

	# Add it to the wikilist.
	mkpath("$ENV{HOME}/.ikiwiki");
	open (WIKILIST, ">>$ENV{HOME}/.ikiwiki/wikilist") || die "$ENV{HOME}/.ikiwiki/wikilist: $!";
	print WIKILIST "$ENV{USER} $config{dumpsetup}\n";
	close WIKILIST;
	if (system("ikiwiki-update-wikilist") != 0) {
		print STDERR "** Failed to add you to the system wikilist file.\n";
		print STDERR "** (Probably ikiwiki-update-wikilist is not SUID root.)\n";
		print STDERR "** Your wiki will not be automatically updated when ikiwiki is upgraded.\n";
	}
	
	# Done!
	print "\n\nSuccessfully set up $config{wikiname}:\n";
	foreach my $key (qw{url srcdir destdir repository}) {
		next unless exists $config{$key};
		print "\t$key: ".(" " x (10 - length($key)))." ".
			prettydir($config{$key})."\n";
	}
	print "To modify settings, edit ".prettydir($config{dumpsetup})." and then run:\n";
	print "	ikiwiki -setup ".prettydir($config{dumpsetup})."\n";
	exit 0;
}

1
