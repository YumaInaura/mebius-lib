
package main;
use strict;

#-----------------------------------------------------------
# �����ւ̐V���j���[�X��\��
#-----------------------------------------------------------
sub news_auth{

# �錾
my(%account,$news_comment_line);
my(%friends_friend,$friend_friends_line);
our(%in);

# CSS��`
$main::css_text .= qq(
table.news_list{width:100%;}
);

# �A�J�E���g���J��
(%account) = Mebius::Auth::File("",$in{'account'});

# �����Ŗ����ꍇ
if(!$account{'editor_flag'}){ main::error("�A�J�E���g��/�Ǘ��҂łȂ��ƐV���f�[�^�͌����܂���B"); }

	# �����̃}�C���r���N�ƃ}�C���r�ɂȂ������̈ꗗ���擾
	if($account{'editor_flag'}){
		(%friends_friend) = Mebius::Auth::FriendsFriendIndex("Get-index",$account{'file'});
		$friend_friends_line = qq(<h2$main::kstyle>$main::friend_tag��$main::friend_tag</h2>\n<div>$friends_friend{'index_line'}</div>\n);
	}


# �L�̃C���f�b�N�X���擾
require "${main::int_dir}auth_vote.pl";
my($index_line_vote) = Mebius::Auth::Vote::Data("Index Not-get-account",$account{'file'},5);

($news_comment_line) = Mebius::Auth::News("Index All",$account{'file'});

# HTML
my $print =  qq(
$news_comment_line
$friend_friends_line
<h2$main::kstyle_h2>�L</h2>
<table class="width100">
$index_line_vote
</table>
);

# �w�b�_
auth_html_print($print,"�V�����",\%account);

exit;

}



1;