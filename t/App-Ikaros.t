use strict;
use warnings;
use Test::More;
use App::Ikaros;
use File::Temp qw//;
use IO::Handle;
use Net::OpenSSH;

plan skip_all =>  "SSH client not found"
    if `shh -V 2>&1`;

my $ssh = Net::OpenSSH->new(
    host => 'localhost',
    timeout => 15,
    strict_mode => 0,
);
plan skip_all => 'Unable to establish SSH connection to localhost!'
    if $ssh->error;


my $default_dir = File::Temp->newdir();
my $override_dir1 = File::Temp->newdir();
my $conf_fh = File::Temp->new( UNLINK => 1, SUFFIX => '.yaml' );
$conf_fh->autoflush(1);
$conf_fh->print(<<"END");
default:
  runner: prove
  workdir: $default_dir

hosts:
  - localhost:
      runner: prove
      workdir: $override_dir1

plan:
  prove_tests:
    - t/plan/test1.plan

END

my $status = App::Ikaros->new({
    config  => $conf_fh->filename,
})->launch(sub {
     my @failed_tests = @{+shift || []};
     print 'failed_tests: ', scalar @failed_tests, "\n";
});

pass('ikaros done');

done_testing;
