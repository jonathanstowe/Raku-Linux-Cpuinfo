use v6;

class Linux::Cpuinfo::Cpu:ver<v0.0.1>:auth<github:jonathanstowe> {
   has %.fields;
   multi method new(Str $cpu ) {
      my %fields;

      for $cpu.lines -> $line {
         my ($key, $value) =  $line.split(/\s*\:\s*/);
         $key.=subst(/\s+/,'_', :g);

         if  $value.defined {
            if $value ~~ /^yes|no$/ {
               $value = so $/ eq 'yes';
            }
            elsif $value ~~ /^<:Nd>+\.?<:Nd>?$/ {
               $value = $value + 0;
            }
         }
         given $key {
            when 'flags' {
               my @flags = $value.split(/\s+/);
               $value = @flags;
            }
         }

         %fields{$key.lc} = $value;

      }
      self.new(:%fields);
   }

   # This needs to be separate as the object itself is needed.
   submethod BUILD(:%!fields ) {
      for %!fields.keys -> $field {
         if not self.can($field) {
            self.^add_method($field, { %!fields{$field} } );
         }
      }
   }
}
