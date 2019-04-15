
package main;
use Mebius::Auth;
use Mebius::SNS::Diary;
use Mebius::Export;

#-------------------------------------------------
# �v���t�B�[���\��
#-------------------------------------------------
sub auth_avhistory{

# �Ǐ���
my($file,$domain_links);
my(%account,$auth_history_line,$rireki_index1,$data_is_here,%res_diary,$res_diary_index,%comment_history);
my($comment_history_line);

#�����`�F�b�N
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# CSS��`
$main::css_text .= qq(
.lim{margin-bottom:0.3em;line-height:1.25;}
li{line-height:1.5;}
td{padding:0.3em 2em 0.3em 0em;}
th{text-align:left;}
);

# �t�@�C���I�[�v��
(%account) = Mebius::Auth::File("",$file);

# ���[�U�[�F�w��
if($account{'color1'}){ $css_text .= qq(h2{background-color:#$account{'color1'};border-color:#$account{'color1'};}); }

# �^�C�g����`
$sub_title = "$account{'name'}�̗��� | $server_domain";
$head_link3 = qq(&gt; <a href="${auth_url}$account{'file'}/">$account{'file'}</a>);
$head_link4 = qq(&gt; ���� ( $server_domain ));


	# ���o���̐��`
	if($account{'ohistory'} =~ /^(use-close)$/){ $auth_history_mark = qq( �i����J�j); }
	else{ $auth_history_mark = qq( �i���J�j); }


	# SNS�̍s���������擾
	if($account{'ohistory'} =~ /^(use-close)$/ && !$account{'editor_flag'}){

	}
	else{
		($auth_history_line) = Mebius::Auth::History("Index",$account{'file'});
		if($auth_history_line){ $auth_history_line = qq(<h2>SNS�̗���$auth_history_mark</h2>\n<div class="line-height-large">$auth_history_line</div>); $data_is_here = 1; }
		else{ $auth_history_line = qq(<h2>SNS�̗���$auth_history_mark</h2>\n<div>�܂�����܂���B</div>); }
		if($account{'ohistory'} =~ /^(use-close)$/){
		}
	}


	# ���L�̓��e�������擾
	if($account{'editor_flag'} || $account{'ohistory'} !~ /^(use-close)$/){
		my($plustyle);
			if($account{'myprof_flag'}){ $plustype_resdiary .= qq( Allow-renew-news); }

		(%res_diary) = Mebius::SNS::Diary::comment_history("Get-index $plustype_resdiary",$file);
	}


	# �`���̓��e�������擾
	if($account{'editor_flag'} || $account{'ohistory'} !~ /^(use-close)$/){
		require "${main::int_dir}auth_comment.pl";
		(%comment_history) = Mebius::Auth::CommentBoadHistory("Get-index",$file);

			# ���`
			if($comment_history{'index_line'}){
				$comment_history_line .= qq(<h2$main::kstyle_h2 id="COMMENT_HISTORY">�`���̃R�����g����$auth_history_mark</h2>\n);
				$comment_history_line .= qq($comment_history{'index_line'});

			}
	}


	if($res_diary{'index_line'}){
		shift_jis($res_diary{'index_line'});
		$res_diary_index .= qq(<h2$main::kstyle_h2 id="DIARY">���L�̃R�����g����$auth_history_mark</h2>\n);
		$res_diary_index .= qq($res_diary{'index_line'}\n);
	}

	if($account{'myprof_flag'}){
		$rireki_index .= qq(<h2$main::kstyle_h2>�f����$rireki_index_mark</h2><div>�f���̓��e�����̓}�C�y�[�W�ł��m�F���������B</div>\n);
	}



# �i�r
my $link2 = "${auth_url}${file}/";
my($navilink);

$navilink .= qq( <a href="$link2">�v���t�B�[����</a>);
$navilink .= qq( <a href="javascript:history.go(-1)">�O�̉�ʂ�</a>);

# HTML
my $print .= <<"EOM";
$footer_link
<h1>���� �F $account{'name'}  - $server_domain</h1>
$navilink
$domain_links
$res_diary_index
$comment_history_line
$auth_history_line
$rireki_index1
$rireki_index
EOM

$print .= qq($footer_link2);

Mebius::Template::gzip_and_print_all({},$print);

# �����I��

exit;
}

#������������������������������������������������������������
# ���e����
#������������������������������������������������������������
sub auth_get_avhistory{

# �t�@�C����`
my($type,$file,%account) = @_;
$file =~ s/[^0-9a-z]//g;

# �Ǐ���
my($line,$i);
my($rireki_index1,$rireki_index2);

# ���e�����t�@�C�����J��
require "${int_dir}part_history.pl";
($none,$none,$rireki_index1) = &get_reshistory("ACCOUNT INDEX Open-view","$file");

return($rireki_index1)

}


#������������������������������������������������������������
# ���e����
#������������������������������������������������������������

sub auth_get_avhistory_old{

# �t�@�C����`
my($type,$file) = @_;
my($i,$rireki_index,$oldhistory_handler);

# ���e�����t�@�C�����J��
open($oldhistory_handler,"${int_dir}_history/${file}_hst.cgi");
	while(<$oldhistory_handler>){
		chomp $_;
		$i++;
		my($key,$sub,$no2,$res,$moto2,$title2,$date2) = split(/<>/);
		$rireki_index .= qq(<li><a href="http://$server_domain/_$moto2/$no2.html#S$res">$sub</a> - <a href="http://$server_domain/_$moto2/">$title2</a>);
	}
close($oldhistory_handler);

return($rireki_index);

}



1;
