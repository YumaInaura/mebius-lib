
# �錾
package Mebius::Goldcenter;
use strict;

#-----------------------------------------------------------
# ���[�h�U�蕪���i�Q�j
#-----------------------------------------------------------
sub item{

# �錾
my($script_mode,$gold_url,$title) = &init();

# �^�C�g����`
$main::sub_title = "�A�C�e���V���b�v | $title";
$main::head_link3 = qq( &gt; <a href="item.html">�A�C�e���V���b�v</a> );

# ���[�h�U�蕪��
if($main::submode2 eq ""){ &index_item(); }
else{ main::error("�y�[�W�����݂��܂���B"); }

}

#-----------------------------------------------------------
# �A�C�e���V���b�v�C���f�b�N�X
#-----------------------------------------------------------
sub index_item{

# �錾
my($type) = @_;
my($script_mode,$gold_url,$title) = &init();

# �^�C�g����`
$main::head_link3 = qq( &gt; �A�C�e���V���b�v );

# HTML
my $print = qq(<h1>�A�C�e���V���b�v - $title</h1>);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;
