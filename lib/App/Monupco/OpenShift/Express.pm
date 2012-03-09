#!/usr/bin/env perl

#####################################################################################
#
# Copyright (c) 2012, Alexander Todorov <atodorov()otb.bg>. See POD section.
#
#####################################################################################

package App::Monupco::OpenShift::Express;
our $VERSION = '0.02';
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

 This module is free software and is published under the same terms as Perl itself.

=cut