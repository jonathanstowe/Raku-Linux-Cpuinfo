use v6;

use Linux::Cpuinfo::Cpu;

class Linux::Cpuinfo:ver<v0.0.1>:auth<github:jonathanstowe> {
   has Str $.filename = '/proc/cpuinfo';
   has Linux::Cpuinfo::Cpu @.cpus;
   has Int $.num_cpus;
   has Str $.arch = $*KERNEL.hardware;
   has $.cpu_class;

   multi method cpus() {
      if not @!cpus.elems > 0 {
         my Buf $buf = Buf.new;

         my $proc = open $!filename, :bin;

         my Bool $last = False;

         while not $last {
             my $tmp_buf = $proc.read(1024);
             $last = $tmp_buf.elems < 1024;
             $buf ~= $tmp_buf;
         }

         my $proc_str = $buf.decode;

         for $proc_str.split( /\n\n/ ) -> $cpu {
             if $cpu.chars > 0 {
               my $co = self.cpu_class.new($cpu);

               # It seems that single core arm6 or 7 cores highlight
               # a bug where there is a spurious \n in there
               # The alert will correctly surmise this breaks for assymetric cpus

               if @!cpus.elems > 0 and @!cpus[*-1].fields.elems != $co.fields.elems {
                  @!cpus[*-1].fields.push($co.fields.pairs);
               }
               else {
                  @!cpus.push($co);
               }
            }
         }
      }
      @!cpus;
   }

   #| Build a sub class of Linux::Cpuinfo::Cpu
   multi method cpu_class() {
      if not $!cpu_class.isa(Linux::Cpuinfo::Cpu) {
         my $class_name = 'Linux::Cpuinfo::Cpu::' ~ $!arch.tc;
         $!cpu_class := Metamodel::ClassHOW.new_type(name => $class_name);
         $!cpu_class.^add_parent(Linux::Cpuinfo::Cpu);
         $!cpu_class.^compose;
      }
      $!cpu_class;
   }

   method num_cpus() {
      if not $!num_cpus.defined {
         $!num_cpus = self.cpus.elems;
      }
      $!num_cpus;
   }
}
