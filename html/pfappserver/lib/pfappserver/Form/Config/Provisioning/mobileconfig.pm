package pfappserver::Form::Config::Provisioning::mobileconfig;

=head1 NAME

pfappserver::Form::Config::Provisioning - Web form for a switch

=head1 DESCRIPTION

=cut

use pf::config;
use HTML::FormHandler::Moose;
extends 'pfappserver::Form::Config::Provisioning';
with 'pfappserver::Base::Form::Role::Help';

has_field 'company' =>
  (
   type => 'Text',
  );

has_field 'ssid' =>
  (
   type => 'Text',
   label => 'SSID',
  );

has_field 'broadcast' =>
  (
   type => 'Checkbox',
   label => 'Broadcast network',
   value => 'true',
   checkbox_value => 'false',
   tags => { after_element => \&help,
             help => 'Check this box if your network is using a hidden SSID' },
  );

has_field 'security_type' =>
  (
   type => 'Select',
   multiple => 0,
   label => 'Security type',
   options_method => \&option_security,
   element_class => ['chzn-deselect'],
   tags => { after_element => \&help,
             help => 'Select the type of security applied for your SSID' },
  );

has_field 'eap_type' =>
  (
   type => 'Select',
   multiple => 0,
   label => 'EAP type',
   options_method => \&options_eap_type,
   element_class => ['chzn-deselect'],
   tags => { after_element => \&help,
             help => 'Select the EAP type of your SSID' },
  );

has_field 'passcode' =>
  (
   type => 'Text',
   label => 'Wifi Key',
  );

has_field 'reversedns' =>
  (
   type => 'Text',
   label => 'ReverseDNS identifier',
   tags => { after_element => \&help,
             help => 'Example : if your dns name is www.packetfence.org it becomes org.packetfence.www'},
  );

has_field 'ca_cert' =>
  (
   type => 'TextArea',
   element_class => ['input-xxlarge'],
   inflate_default_method => \&filter_inflate ,
   deflate_value_method => \&filter_deflate ,
   label => 'The base64 Certificate of Authority',
   tags => { after_element => \&help,
             help => 'The Certificate of Authority in pem format'},
  );

has_field 'certificate' =>
  (
   type => 'TextArea',
   label => 'The certificate for signing profiles',
   inflate_default_method => \&filter_inflate ,
   deflate_value_method => \&filter_deflate ,
   element_class => ['input-xxlarge'],
   tags => { after_element => \&help,
             help => 'The Certificate for signing in pem format'},
  );

has_field 'private_key' =>
  (
   type => 'TextArea',
   element_class => ['input-xxlarge'],
   inflate_default_method => \&filter_inflate ,
   deflate_value_method => \&filter_deflate ,
   label => 'The private key for signing profiles',
   tags => { after_element => \&help,
             help => 'The Private Key for signing in pem format'},
  );

has_field 'can_sign_profile' =>
  (
   type => 'Checkbox',
   label => 'Sign Profile',
   value => 0,
   checkbox_value => 1,
   tags => { after_element => \&help,
             help => 'Check this box if you want the profiles signed' },
  );

sub filter_inflate {
    my ($self, $value) = @_;
    if(ref($value) eq 'ARRAY' ) {
         return (join("\n",@{$value}));
    }
    return $value;
}

sub filter_deflate {
    my ($self, $value) = @_;
    return [split /\r?\n/,$value];
}



has_block definition =>
  (
   render_list => [ qw(id description reversedns type category ssid broadcast eap_type security_type passcode pki_provider can_sign_profile private_key ca_cert certificate ) ],
  );

sub options_eap_type {
    my $self = shift;
    my @eap_types = ["25" => "PEAP",
                     "13" => "EAP-TLS",
                     "21" => "EAP-TTLS",
                     ""   => "No EAP",
                    ];
    return @eap_types;
}

sub option_security {
    my $self = shift;
    my @security_type = ["None" => "Open",
                         "WEP" => "WEP",
                         "WPA" => "WPA",
                         "WPA" => "WPA2",
                        ];
    return @security_type;
}

=head1 COPYRIGHT

Copyright (C) 2005-2015 Inverse inc.

=head1 LICENSE

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301,
USA.

=cut

__PACKAGE__->meta->make_immutable;
1;
