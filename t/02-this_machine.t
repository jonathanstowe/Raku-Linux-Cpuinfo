#!perl6

use v6;

use Test;
use lib "lib";

use Linux::Cpuinfo;

ok(my $ci = Linux::Cpuinfo.new, "new Linux::Cpuinfo - no args");
isa_ok($ci, Linux::Cpuinfo, "and it is the right sort of object");
ok($ci.num_cpus > 0, "got some CPUs");

my $count_cpus = 0;
for $ci.cpus -> $cpu {
   $count_cpus++;
   isa_ok($cpu, Linux::Cpuinfo::Cpu, "the CPU is the right type of object");
   is($cpu.^name, 'Linux::Cpuinfo::Cpu::' ~ $ci.arch.tc, "and the right sub-type");

   for $cpu.fields.keys -> $field {
      ok($cpu.can($field), "and the object has a $field method");
   }
}

is($ci.num_cpus, $count_cpus, "and we saw as many cpus as we expected");

done();