
use Mebius::AuthServerMove;

#-----------------------------------------------------------
# SNS ���O�A�E�g
#-----------------------------------------------------------
sub auth_logout{
if($in{'action'}){ &do_logout; } else{ &view_logout; }
}

#-----------------------------------------------------------
# ���O�A�E�g�O�̉��
#-----------------------------------------------------------
sub view_logout{

my $print = qq(
�{���Ƀ��O�A�E�g���܂����H<br><br>

<form action="$main::auth_url" method="post"$sikibetu>
<div>
<input type="hidden" name="mode" value="logout">
<input type="submit" name="action" value="$pmfile ���烍�O�A�E�g����">
<input type="hidden" name="logout_doned" value="1">
</div>
</form>


$footer_link
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


#-------------------------------------------------
# ���O�A�E�g
#-------------------------------------------------
sub do_logout{

# �錾
my($basic_init) = Mebius::basic_init();
my($none,$next,$logout_doned);

	# Get���M���֎~
	if(!$main::postflag){ main::error("GET���M�͂ł��܂���B"); }

# ��d�N�b�L�[�Z�b�g��h�~
$no_headerset = 1;

# �N�b�L�[���Z�b�g
Mebius::Cookie::set_main({ account => "" , hashed_password => "" , } );

# �^�C�g���Ȃǒ�`
$head_link3 = qq(&gt; ���O�A�E�g);

# �W�����v
$jump_url = $auth_url;
$jump_sec = 5;


my($action_url) = Mebius::Auth::ServerMove("All-domains",$main::server_domain);

	# �e�T�[�o�[�Ń��O�A�E�g
	if($main::in{'logout_doned'} < $basic_init->{'number_of_domains'}){
		
		$logout_doned = $main::in{'logout_doned'} + 1;

		$next = qq(
		<form action="$action_url" method="post"$sikibetu>
		<div>
		���܂����O�A�E�g�ł��Ȃ��ꍇ��
		<input type="hidden" name="mode" value="logout">
		<input type="hidden" name="logout_doned" value="$logout_doned">
		<input type="submit" name="action" value="���̃{�^���������Ă�������($logout_doned)">
		</div>
		</form>
		<br><br>);

			if($main::myadmin_flag >= 5){ $next .= qq(); }

	}

my $print = <<"EOM";
���O�A�E�g���܂����B�i<a href="${auth_url}">��$title��</a>�j<br><br>
$next
$footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

1;
