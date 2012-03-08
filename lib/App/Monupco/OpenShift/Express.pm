#!/usr/bin/env perl

#####################################################################################
#
# Copyright (c) 2012, Alexander Todorov <atodorov()otb.bg>. See POD section.
#
#####################################################################################

package App::Monupco::OpenShift::Express;
our $VERSION = '0.01';
our $NAME = "monupco-openshift-express-perl";

use App::Monupco::OpenShift::Express::Parser;
@ISA = qw(App::Monupco::OpenShift::Express::Parser);

use strict;
use warnings;

use JSON;
use LWP::UserAgent;

my $data = {
    'user_id'    => $ENV{'MONUPCO_USER_ID'},
    'app_name'   => $ENV{'OPENSHIFT_APP_NAME'},
    'app_uuid'   => $ENV{'OPENSHIFT_APP_UUID'},
    'app_type'   => $ENV{'OPENSHIFT_APP_TYPE'},
    'app_url'    => "http://$ENV{'OPENSHIFT_APP_DNS'}",
    'app_vendor' => 0,   # Red Hat OpenShift Express
    'pkg_type'   => 400, # Perl / CPAN
    'installed'  => [],
};

my $pod_parsed = "";
my $parser = Monupco::OpenShift::Express::Parser->new();
$parser->output_string( \$pod_parsed );
$parser->parse_file("$ENV{'OPENSHIFT_DATA_DIR'}/perl5lib/lib/perl5/x86_64-linux-thread-multi/perllocal.pod");

my @installed;
foreach my $nv (split(/\n/, $pod_parsed)) {
    my @name_ver = split(/ /, $nv);
    push(@installed, {'n' => $name_ver[0], 'v' => $name_ver[1]});
}


$data->{'installed'} = [ @installed ];

my $json_data = to_json($data); # , { pretty => 1 });

my $ua = new LWP::UserAgent(('agent' => "$NAME/$VERSION"));

# will URL Encode by default
my $response = $ua->post('https://monupco-otb.rhcloud.com/application/register/', { json_data => $json_data});

if (! $response->is_success) {
    die $response->status_line;
}

my $content = from_json($response->decoded_content);
print "Monupco: $content->{'message'}\n";

exit $content->{'exit_code'};


1;
__END__

=head1 NAME

Monupco::OpenShift::Express - monupco.com registration agent for OpenShift Express / Perl applications

=head1 SYNOPSIS

  use Monupco::OpenShift::Express;

=head1 DESCRIPTION

This module compiles a list of locally installed Perl distributions and sends it to
http://monupco.com where you check your application statistic and available updates.

=head1 AUTHOR

Alexander Todorov, E<lt>atodorov()otb.bgE<gt>

=head1 COPYRIGHT AND LICENSE

 Copyright (c) 2012, Alexander Todorov <atodorov()otb.bg>

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.

=cut
