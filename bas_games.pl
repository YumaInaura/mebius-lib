
package Mebius::Games;
use strict;

#-----------------------------------------------------------
# �ݒ�
#-----------------------------------------------------------
sub init_start_games{

$main::sub_title = "���r�Q�[";
$main::head_link2 = qq(&gt; <a href="/_games/">���r�Q�[</a>);

}

#-----------------------------------------------------------
# ���[�h�U�蕪��
#-----------------------------------------------------------
sub start_games{

# �X�N���v�g��`
our $script = "/_games/";
my($redirect_uri);


	$main::head_link1 = qq( &gt; <a href="http://aurasoul.mb2.jp/">�ʏ��</a> | <a href="http://mb2.jp/">��y��</a>);
	$main::head_link1 = 0;

	# �g�уA�C�e�����擾
	if($main::in{'k'}){ main::kget_items(); }

	# �A�N�Z�X�U�蕪��
	if($main::in{'k'} eq "" && $main::device_type eq "mobile" && $main::requri && $main::requri !~ /imode/ && !$main::postflag){
		Mebius::Redirect("","http://$main::server_domain/imode$main::requri");
	}

	# �A�N�Z�X�U�蕪��
	if($main::in{'k'} && $main::device_type eq "desktop" && $main::requri && $main::requri =~ /imode/ && !$main::postflag){
		$redirect_uri = $main::requri;
		$redirect_uri =~ s|imode/||g;
		Mebius::Redirect("","http://$main::server_domain$redirect_uri");
	}


	# ���[�h�U�蕪��
	if($main::in{'game'} eq ""){ &Index(); }
	#if($main::in{'game'} eq "dungeon"){ require "${main::int_dir}games_dungeon.pl"; Mebius::Dungeon::Mode(); }
	#else{ main::error("�y�[�W�����݂��܂���B"); }
	main::error("�y�[�W�����݂��܂���B[gms]");

	exit;

}


#-----------------------------------------------------------
# �Q�[���̊�{�ݒ���擾
#-----------------------------------------------------------
sub Init{

	# Docomo�� utn ���ꊇ��`
	our $utn2 = undef;
	if($main::k_access eq "DOCOMO"){ $utn2 = qq( utn="utn"); }

return(undef,undef,$utn2);

}



#-----------------------------------------------------------
# �C���f�b�N�X
#-----------------------------------------------------------
sub Index{

$main::head_link2 = qq(&gt; ���r�Q�[);


# HTML
my $print = qq(
<h1>���r�Q�[</h1>
<ul>
<li><a href="dungeon/">�_���W�������[�N</a></li>
<li><a href="http://aurasoul.mb2.jp/gap/ff/ff.cgi">���r�����E�A�h�x���`���[</a></li>
</ul>
);


Mebius::Template::gzip_and_print_all({},$print);

exit;



}



1;
