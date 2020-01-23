use strict; use warnings;
package TestMLBridge;
use base 'TestML::Bridge';

use Capture::Tiny 'capture_merged';

BEGIN {
    $ENV{PATH} = "./bin:$ENV{PATH}";
}

sub run {
  my ($self, $command) = @_;

  capture_merged {
      system $command
  };
}

1;
