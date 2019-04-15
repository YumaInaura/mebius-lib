
package main;
use Mebius::Export;

#-----------------------------------------------------------
# �L�[���[�h�y�[�W
#-----------------------------------------------------------
sub auth_wordtag{

# �Ǐ���
my($type,$file,$maxtag,$max_comment) = @_;
my($line,$file,$ads,$i,$form,$myflag,$fook_submit);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;
our($selfurl_enc);

# CSS��`
$css_text .= qq(
h1{display:inline;}
table{width:100%;}
th{text-align:left;}
th.name{width:25%;}
th.tag{width:3.25em;}
th,td{padding:0.4em 0.2em;}
.sponsored{font-weight:bold;background-color:#dee;padding:0.3em 0.5em;font-size:90%;border:solid 1px #0aa;}
.ads{}
.comment_input{width:20em;}
div.alert{font-size:90%;background-color:#fff;padding:1em;margin-top:1em;border:solid 1px #f00;}
.google_link{font-size:150%;}
.inline{display:inline;}
.fook_tag{color:#070;margin-left:1.5em;display:inline;font-size:90%;word-spacing:0.3em;}
.fook_input{font-size:80%;width:8em;}
.fook_submit{font-size:80%;}
.inline{display:inline;}
tr.me{background-color:#ff7;padding-left:0.5em;margin:0.3em 0.0em;}
li{line-height:1.7;}
span.alert{font-size:90%;color:#f00;}
);

# �^�C�g����`
$sub_title = qq($submode3 | SNS �^�O);
$head_link3 = qq( &gt; $submode3 - �^�O);

$file2 = $submode3;
$file2 =~ s/([^\w])/'%' . unpack('H2' , $1)/eg;
$file2 =~ tr/ /+/;

my $log_file2 = "${auth_log_directory}_tag/$file2.cgi";

# ���t�@�C�����`�F�b�N
open(CLOSE_IN,"<","${auth_log_directory}_closetag/${file2}_close.cgi");
$top_close = <CLOSE_IN>;
my($close_key,$admin_alert,$remove) = split(/<>/,$top_close);
close(CLOSE_IN);

# �Ǘ��҂̌x��
if($admin_alert){
$admin_alert_text = &auth_auto_link($admin_alert);
$admin_alert_area = qq(<h2>�Ǘ��҂��</h2><strong class="red">$admin_alert_text</strong>);
}

# �L�[���[�h�t�@�C�����J��
open(TAG_IN,"<",$log_file2);
	while(<TAG_IN>){
		chomp;
		my($key,$account,$name,$comment,$deleter,$date2) = split(/<>/,$_);

		my($class);
		if($key ne "1" && !$myadmin_flag){ next; }
		if($account eq $pmfile){ $myflag = 1; $comment_value = "$comment"; $class = qq( class="me"); }
		if($key eq "1"){ $i++; }
		if($comment ne ""){ $comment = &auth_auto_link($comment); }
		$line .= qq(<tr$class><td><a href="./$account/">$name - $account</a></td>);
		$line .= qq(<td><a href="./$account/tag-view">���^�O</a></td><td>$comment);


		$line .= qq(</td>);
		$line .= qq(<td>$date2</td>);

		# �폜�p�����N
		$line .= qq(<td class="right">);
			if($pmfile eq $account || $myadmin_flag){
				$line .= qq(<a href="./?mode=tag-delete-$file2&amp;account=$account">�폜</a>);
					if($myadmin_flag){
						$line .= qq( - ( <a href="./?mode=tag-delete-$file2&amp;account=$account&amp;penalty=1">�y�i���e�B�폜</a> ));
					}
			}
		$line .= qq(</td>);

		$line .= qq(</tr>\n);
	}
close(TAG_IN);

# �o�^���[���̏ꍇ
if(!$i){ $i = 0; }

# �����N�؂�̏ꍇ�A�C���t�H�[����\������
	if(!-f $log_file2 || $close_key eq "0" || $line eq ""){
		&repairform();
	}

# �L���t�B���^����
my($fillter_flag) = Mebius::Fillter::Ads({ FromEncoding => "sjis" },$submode3);
	Mebius::Fillter::fillter_and_error(utf8_return($submode3));

# �L��
if(!$noads_mode && !$fillter_flag && !$alocal_mode && $i){ $ads = qq(
<br><br>
<div class="sponsored">�X�|���T�[�h�����N</div><br>
<script type="text/javascript"><!--
google_ad_client = "ca-pub-7808967024392082";
/* SNS�r�b�O�o�i�[ */
google_ad_slot = "4432696952";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
);
}

# �����A���b�N���̏ꍇ
if($close_key eq "0"){
if($myadmin_flag){ $close_text = qq(<strong class="red">�����̃^�O�͕����ł��B$admim_alert_text</strong><br><br>); }
else{ &error("���̃^�O�͕����ł��B$admim_alert_text","410 Gone"); }
}
elsif($close_key eq "2"){
$ads = "";
$close_text = qq(<strong class="red">�����̃^�O�̓��b�N����Ă��܂��B$admim_alert_text</strong><br><br>); 
$lock_flag = 1;
}

# �y�[�W�����݂��Ȃ��ꍇ
if(!-f $log_file2){ &error("���̃^�O�͂܂����݂��܂���B"); }

# �Q�����A�J�E���g���Ȃ��ꍇ
if($line eq ""){ &error("�o�^������܂���B"); }

# ���C���̐��`(�Q���A�J�E���g������ꍇ�j
else{
$line = qq(

<h2>�Q���A�J�E���g ($i)</h2>
<table summary="�^�O�o�^�̈ꗗ">
<tr><th class="name">�M��</th><th class="tag">�����N</th><th>�R�����g</th><th>����</th><th></th></tr>
$line
</table>

);
}


# �^�O�����t�H�[�����擾
&get_schform;



# �Q�����̏ꍇ
my($up_input,$edit_input);
if($myflag){
$h22 = qq(�R�����g��ҏW);
$edit_input = qq(<input type="hidden" name="edit" value="1">);
$submit_value = qq(�R�����g��ҏW����);
$up_input = qq(<input type="checkbox" name="up" value="1"> �R�����g�ʒu���A�b�v);
}

# �Q�����Ă��Ȃ��ꍇ
else{
$h22 = qq(���̃^�O�ɎQ��);
$submit_value = qq(�^�O \($submode3\) ��ǉ�����);
}

	# �^�O���b�N���̏ꍇ
	if($lock_flag){}

	# �X�g�b�v���[�h
	elsif($main::stop_mode =~ /SNS/){
		$form = qq(<h2>$h22</h2>\n<div><span class="alert">���݁ASNS�S�̂ōX�V��~���ł��B</span></div>\n);
	}

# �L�[���[�h���Q���t�H�[��
elsif($pmfile){
$form = qq(
<h2>$h22</h2>
<form action="$action" method="post" class="myform"$sikibetu>
<div>

<input type="hidden" name="tag" value="$submode3">
�R�����g�F <input type="text" name="comment" value="$comment_value" maxlength="$max_comment" class="comment_input">
<input type="submit" value="$submit_value">
$up_input
$edit_input
<br><span class="alert">���^������^�O�ɂ̂ݓo�^���Ă��������B�u�ᔻ�o�^�v�u���Γo�^�v��u�^�O���ł̋c�_�v�͂��������������B</span>

<input type="hidden" name="mode" value="tag-maketag">
<input type="hidden" name="plus" value="1">
<input type="hidden" name="account" value="$pmfile">
<br>
<div class="alert">
���^�O ( $submode3 ) �ɎQ���ł��܂��B<br>
<span class="red">���l���A�{���A���I�ȃL�[���[�h�A�o�b�V���O�ړI�A���ړI�A���Ӗ��ȒP��A���f�ȓ��e�Ȃǂ̓o�^�͋֎~�ł��B((<a href="${guide_url}%A5%BF%A5%B0">���^�O�ɂ���</a>))</span><br>
���^�O�͉����ɔ��΂�����A�������U���E�ᔻ�E���邽�߂��̂ł͂���܂���B�����������Ȃ��ɂ�<a href="http://aurasoul.mb2.jp/">�f����</a>�𗘗p���Ă��������B<br>
���^�c�v�]�Ȃǂ́A�^�O�ł͂Ȃ�<a href="http://mb2.jp/_qst/">����^�c��</a>�܂ł��肢���܂��B<br>
���s�K�؂ȃ^�O�E�R�����g��<a href="http://mb2.jp/_delete/166.html">�y���r�����r�m�r�z�@�s�����p��</a>�܂ł��A�����������B
</div>
</div>
</form>

);


}

# ���O�C�����Ă��Ȃ��ꍇ
else{
$form = qq(
<h2>$h22</h2>
�����̃^�O�ɎQ������ɂ�<a href="${auth_url}?backurl=$selfurl_enc">���O�C���i�܂��̓����o�[�o�^�j</a>���Ă��������B<br>
);
}

# �Ǘ��҂̏ꍇ�A�L�[���[�h���t�H�[��
if($myadmin_flag){
$closelink .= qq(<br><br><form method="post" class="inline" action="$action"><div class="inline">);
$closelink .= qq(<input type="hidden" name="mode" value="tag-close-$file2"$main::xclose>);
$closelink .= qq( <strong class="red">�Ǘ��Ґ�p�F</strong> ���� <input type="text" name="text" value="$admin_alert" class="comment_input"$main::xclose>);
if($close_text){ $closelink .= qq( <input type="checkbox" name="type" value="revibe" id="tag_revive"$main::xclose> <label for="tag_revive">�L�[���[�h����</label> ); }
else{ $closelink .= qq( <input type="checkbox" name="type" value="close" id="tag_close"$main::xclose><label for="tag_close">�L�[���[�h��</label> ); }
$closelink .= qq( <input type="checkbox" name="type" value="lock" id="tag_lock"$main::xclose><label for="tag_lock">���b�N</label> );
$closelink .= qq(<input type="submit" value="�ݒ�"$main::xclose>);
$closelink .= qq(</div></form>);
}



# Google���������N
my $search_link = qq(
<a href="http://www.google.co.jp/search?q=$file2&amp;sitesearch=mb2.jp&amp;ie=Shift_JIS&amp;oe=Shift_JIS&amp;hl=ja&amp;domains=mb2.jp" class="google_link" rel="nofollow">���h$submode3�h��Google�������Ă݂�</a><br><br>
);

# ���O�C�����̏ꍇ�A�^�O�o�^�����N
my($link1);
if($idcheck){ $navilink = qq(<a href="./$pmfile/tag-view">�^�O��o�^����</a>); }
$navilink .= qq( - <a href="./tag-new.html">�V���^�O���`�F�b�N����</a>);

# HTML
my $print = qq(
$footer_link

<h1>$submode3 - SNS�^�O</h1>
$fook_line
<br><br>


$close_text
$search_link
$navilink
$schform
$closelink
$ads
$admin_alert_area
$line
$form
$form2
$footer_link2
);

Mebius::Template::gzip_and_print_all({ no_ads_flag => $fillter_flag },$print);

exit;

}

1;
