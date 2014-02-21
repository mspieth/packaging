#!/usr/bin/perl

use strict;
use POSIX ":sys_wait_h";

my $prevpid = 0;
my $prevpidcnt = 0;
while (1)
{
	my %procs;
	my %procnames;
	open F, "ps ax|";
	while (<F>)
	{
		chomp;
		my ($pid, $ppid, $cmd) = /\s+(\d+)\s+(\d+).*\s(\S+)$/;
		$pid = $pid + 0;
		$ppid = $ppid + 0;
		#print "$pid $ppid $cmd\n";
		$procs{$pid} = $ppid;
		$procnames{$pid} = $cmd;
	}
	my $nprevpid = $prevpid;
	my $found = 0;
	foreach my $pid (keys %procnames)
	{
		#print "testing $procnames{$pid}\n";
		if ($procnames{$pid} eq '<defunct>')
		{
			#system("cmd /c \"taskkill /F /IM $pid\"");
			if ($procs{$pid} == 1)
			{
				#print "waiting for $pid ... ";
				#my $kid = waitpid(-1, WNOHANG);
				#my $kid = waitpid(-1, 0);
				#print "waited for $pid ret $kid\n";
				system("cmd /c \"taskkill /F /IM $pid\"");
				next;
			}
			#print "found defunct $pid '$procs{$pid}'\n";
			if (defined($procs{$procs{$pid}}))
			{
				$found = 1;
				if ($nprevpid == $procs{$pid})
				{
					$prevpidcnt++;
					print "check $procs{$pid} $prevpidcnt\n";
					if ($prevpidcnt >= 21)
					{
						print "kill -KILL $procs{$pid}\n";
						system("kill -KILL $procs{$pid}");
					}
					elsif ($prevpidcnt >= 20)
					{
						print "kill $procs{$pid}\n";
						#system("kill $procs{$pid}");
						system("cmd /c \"taskkill /F /IM $pid\"");
						#$prevpid = 0;
						#$prevpidcnt = 0;
					}
				}
				else
				{
					print "first $procs{$pid}\n";
					$prevpid = $procs{$pid};
					$prevpidcnt = 0;
				}
				last;
			}
		}
	}
	if ($found != 1)
	{
		$prevpid = 0;
	}
	sleep 1;
	#last;
}

