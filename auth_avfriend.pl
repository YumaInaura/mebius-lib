
use Mebius::SNS::Friend;
use Mebius::Export;

#-------------------------------------------------
# �v���t�B�[���\��
#-------------------------------------------------
sub auth_avfriend{

# �Ǐ���
my($file,$i,$navilink,%friends_friend,$friend_friends_line,%my_friend_index);

# CSS��`
$css_text .= qq(
.lim{margin-bottom:0.3em;}
li{line-height:1.6em;}
div.friend_index .my_friend{background:#cfc;padding:0.3em 0.5em;}
div.friend_index .me{background:#fee;padding:0.3em 0.5em;}
);

# �t�@�C���I�[�v��
my(%account) = Mebius::Auth::File("File-check-error",$main::in{'account'});

# ���[�U�[�F�w��
if($account{'color1'}){ $css_text .= qq(h2{background-color:#$account{'color1'}border-color:#$account{'color1'};}); }

# �g���b�v
#if($ppenctrip){ $pri_ppenctrip = "��$ppenctrip"; }

# �A�J�E���g��
my $viewaccount = $account{'file'};
	if($account{'file'} eq "none"){ $viewaccount = "****"; }

# �^�C�g������
$sub_title = "$friend_tag�ꗗ - $account{'name'} - $viewaccount - $title";



	# �����̃}�C���r�Ɣ�ׂ�
	if($main::myaccount{'file'} && !$account{'myprof_flag'}){
		(%my_friend_index) = Mebius::Auth::FriendIndex("Get-friend-hash",$main::myaccount{'file'});
	}

# �}�C���r�ꗗ�̓ǂݍ��݃^�C�v���`
my $plustype_friend_index;
	if($account{'myprof_flag'}){ $plustype_friend_index .= qq(Get-friend-status); }
	if($account{'myprof_flag'}){ $plustype_friend_index .= qq( Allow-renew-status); }

# �}�C���r�ꗗ��ǂݍ���
my(%friend_index) = Mebius::Auth::FriendIndex("Get-index $plustype_friend_index",$account{'file'},%my_friend_index);

	# �����̃}�C���r���N�ƃ}�C���r�ɂȂ������̈ꗗ���擾
	if($account{'editor_flag'}){
		(%friends_friend) = Mebius::Auth::FriendsFriendIndex("Get-index",$account{'file'});
		$friend_friends_line = qq(<h2 style="background:#cdf;border-color:#77f;$main::kstyle_h2_in">$main::friend_tag��$main::friend_tag</h2>\n<div>$friends_friend{'index_line'}</div>\n);
	}

# �i�r
my $link2 = "$adir$account{'file'}/";
if($main::aurl_mode){ ($link2) = &aurl($link2); }

$navilink .= qq( <a href="$link2">$account{'name'}�̃v���t�B�[��</a>);

	if($main::myaccount{'file'}){
			if($account{'myprof_flag'}){
					$navilink .= qq( ���Ȃ���$main::friend_tag);
			}
			else{
					$navilink .= qq( <a href="${main::auth_url}$main::myaccount{'file'}/aview-friend">���Ȃ���$main::friend_tag�ꗗ</a>);
			}
	}

# HTML
my $print = <<"EOM";
$footer_link
<h1$main::kstyle_h1>$friend_tag�ꗗ : $account{'name'} - $viewaccount</h1>
$friendlink
$navilink
$adsarea
$friend_index{'index_line'}
$friend_friends_line
EOM


$print .= qq($footer_link2);

#url => $account{'profile_url'} , title => "�}�C���r"
Mebius::Template::gzip_and_print_all({ BCL => [ "�}�C���r" ] },$print);

# �����I��
exit;

}




1;
