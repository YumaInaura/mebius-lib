
use Mebius::BBS;
package main;

#-----------------------------------------------------------
# �L���f�[�^���{��
#-----------------------------------------------------------
sub bbs_view_data{

# �����ˁI���R
@support_reason = (
'19=�ǂ��R�~���j�P�[�V����',
'2=�ʔ����A��������������',
'13=�D�ꂽ�}�i�[',
'17=���������A���炮',
'9=�m�I�A���l������',
'12=�z��������A�₳����',
'3=�𗧂��',
'6=�G��A��z���Ă���',
'7=�h���I�A�X����������',
'1=�^���A�^�ʖ�',
'16=�M���A��M�I',
'10=��A���I',
'15=���e�ւ̋���',
'18=�Ǝ��̓N�w�A�|���V�[',
'11=�D�ꂽ���{��',
'5=�D�ꂽ�c�_',
'4=�D�ꂽ��i',
'20=�e�������ɂ��g�������ˁI',
'8=�X�V����]����',
'14=���̑�'
);

# �����`�F�b�N
$in{'no'} =~ s/\D//g;

# �g�єł̏ꍇ
if($mode eq "kview" || $in{'k'}){ &kget_items(); }


# �A�N�Z�X�U�蕪�� ( �f�X�N�g�b�v�Ł����o�C���� )
if($mode eq "view"){
#if($device_type eq "mobile"){ &divide($divide_url,"mobile"); }
}

# �A�N�Z�X�U�蕪�� ( ���o�C���Ł��f�X�N�g�b�v�� )
if($mode eq "kview"){
#if($device_type eq "desktop"){ &divide($divide_url,"desktop"); }
}


# �L�� (���݂͖��g�p)
$ads_data = qq(
<h2 class="bgbcolor"$kstyle_h2>�X�|���T�[�h�����N</h2>
<script type="text/javascript"><!--
google_ad_client = "pub-7808967024392082";
/* �L���f�[�^ */
google_ad_slot = "9966248153";
google_ad_width = 728;
google_ad_height = 90;
//-->
</script>
<script type="text/javascript"
src="http://pagead2.googlesyndication.com/pagead/show_ads.js">
</script>
);
if($alocal_mode || $admin_mode || $kflag){ $ads_data = ""; }

	# URL��`
	if($admin_mode){
		$topic_url = "$script?mode=$submode1&amp;no=$in{'no'}";
		$data_url = "${jak_url}$script?mode=$submode1&no=$in{'no'}&r=data";}
	else{
		$topic_url = "$in{'no'}.html";
		$data_url = "http://$server_domain/_$moto/$in{'no'}_data.html";
	}

# ���[�h�U�蕪��
&viewdata_editform();

}

#-----------------------------------------------------------
# �ҏW�y�[�W
#-----------------------------------------------------------

sub viewdata_editform{

# �Ǐ���
my($alert,$line_data,$tag_line,$kr_line);
my($use_paint_checked,%edit_history,$print,@BCL);
our($concept,$css_text,$admin_mode,$postflag);

# CSS��`
my $css_text .= qq(
h1{margin-top:0em;}
h2{padding:0.3em 0.6em;font-size:120%;}
li{line-height:1.5em;}
ul{margin:1em 0em;}
i{font-size:80%;margin-right:0.3em;}
input.subject{width:20em;}
td{padding:0.3em 0.5em 0.3em 0.3em;font-size:90%;}
span.del{color:#f00;font-size:90%;}
table,th,tr,td{border-style:none;text-align:left;}
table{margin:1em 0em;}
div.comment{width:30em;word-wrap;break-word;}
h2.tag{background:#bdd;}
h2.support{background:#fbb;}
h2.kr{background:#bbf;}
);

#table,th,tr,td{border-style:none;}

# �����`�F�b�N
$in{'no'} =~ s/\D//g;
if($in{'no'} eq ""){ &error("�L�����w�肵�Ă��������B"); }

my($thread) = Mebius::BBS::thread({ ReturnRef => 1 , FileCheckError => 1  },$realmoto,$in{'no'});
chomp(my $top1 = $thread->{'all_line'}->[0]);
our($no,$sub,$res,$key,$res_pwd,$t_res,$d_delman,$d_password,$dd1,$sexvio,$dd3,$dd4,$memo_editor,$memo_body,$dd7,$dd8,$juufuku_com,$posttime) = split(/<>/, $top1);

	# �폜�ς݁A���b�N���̋L��
	#if($key eq "4" || $key eq "6" || $key eq "7"){ &error("�폜�ς݁A�܂��̓��b�N���̋L���ł��B"); }
	if($thread->{'keylevel'} <= 0){ &error("�폜�ς݁A�܂��̓��b�N���̋L���ł��B"); }

chomp(my $top2 = $thread->{'all_line'}->[1]);
my($no2,$ranum,$nam,$eml,$com,$dat,$ho,$pw,$url,$mvw,$none,$none,$account) = split(/<>/, $top2);

# �L����`�F�b�N
if($admin_mode || ($pmfile eq $account && $account ne "")) { $mytopic_flag = 1; }

	# �֘A�L���̕ҏW
	if($in{'type'} eq "kr_edit"){

		# GET���M���֎~
		if(!$postflag){ main::error("GET���M�͏o���܂���B"); }

		# �ҏW�����s
		require "${int_dir}part_kr.pl";
		my($success_flag) = related_thread("Edit-data",$moto,$in{'no'});

		# �ҏW�G���[�̏ꍇ
		#if(!$success_flag){ main::error("�ҏW�Ɏ��s���܂����B�l�͔��p�����Ő��������͂��Ă��������B ","","","Not-repair"); }

		# ���_�C���N�g
		Mebius::Redirect("","$data_url#KR");

	}

# �֘A�L���̍폜
if($in{'type'} eq "support_delete"){ &viewdata_support_delete(undef,$main::moto,$in{'no'}); }

# �L������ύX
if($in{'type'} eq "subject_edit"){ &viewdata_subject_edit(undef,$main::moto,$in{'no'}); }

# �֘A�L�����擾
require "${int_dir}part_kr.pl";
	if($mytopic_flag){ ($kr_line) = related_thread("Index Editor",$moto,$in{'no'}); }
	else{ ($kr_line) = related_thread("Index",$moto,$in{'no'}); }

	# �֘A�L���𐮌`
	my ($mytopic_text);
		if($mytopic_flag){ $mytopic_text = qq(�L����̓|�C���g�𑀍�ł��܂��B); }

	# �ҏW�p
	if($mytopic_flag && $kr_line){
		$kr_line = qq(
		<form action="$script" method="post"$sikibetu>
		<div>
		$kr_line
		<input type="hidden" name="mode" value="view"$xclose>	
		<input type="hidden" name="moto" value="$moto"$xclose>	
		<input type="hidden" name="no" value="$in{'no'}"$xclose>	
		<input type="hidden" name="r" value="data"$xclose>	
		<input type="hidden" name="type" value="kr_edit"$xclose>	
		<input type="submit" value="�|�C���g��ҏW����"$xclose>	
		</div>
		</form>
		);
	}


	# �\��
	if($kr_line){
		$kr_line = qq(
		<h2 class="kr" id="KR"$kstyle_h2>�֘A�����N</h2>
		<span class="guide">
		$mytopic_text
		�|�C���g�������قǗD�悵�ĕ\\������A�}�C�i�X���Ɣ�\\���ɂȂ�܂��B
		�܂��A�|�C���g�͗��p�󋵂ɉ����ď㉺���܂��B
		</span>
		$kr_line);
	}

	if($main::mytopic_flag){
		(%edit_history) = Mebius::BBS::ThreadEditHistory("Get-index",$moto,$in{'no'});
	}

# �^�O���擾
if($concept !~ /NOT-TAG/){
($tag_line) = &viewdata_get_tags($key,$sub);
}

# �����ˁI�f�[�^���擾
my($line_support,$line2_support) = &viewdata_get_support();

# �L���������ꍇ
if($res < 10 || $kr_line eq "" || $noads_mode){ $ads_data = ""; }

# �e��f�[�^
$line_data .= qq(���X�F $res�� |);
if($t_res && $posttime && $res && $t_res != $posttime){
my($speed) = int( ($res) / ( ($t_res - $posttime) / (24*60*60) ) * 10 ) / 10;
$line_data .= qq( ���x�F $speed���X/�� | );
}

# ����
$line_data .= qq( �����F <a href="/_$moto/">$title</a> |
�t�q�k�F <a href="http://$server_domain/_$moto/$in{'no'}.html">http://$server_domain/_$moto/$in{'no'}.html</a>
);

	#if($cnumber && !$admin_mode){ $line_data .= qq( | <a href="$script?mode=mylist&amp;no=$in{'no'}">���C�ɓ���o�^</a> ); }

# �^�C�g����`
my $sub_title = "�f�[�^ | $sub";
push @BCL , { url => "$in{'no'}.html" , title => $sub };
push @BCL , "�f�[�^";

	# �L�����ύX�t�H�[��
	if($mytopic_flag && ($key eq "1" || $key eq "5" || $key eq "2" || Mebius->common_admin_judge())){

		# �Ǐ���
		my($sex_input,$vio_input,$sex_checked,$vio_checked);

			# 15��
			if($chowold >= 15 || $admin_mode){
			if($sexvio eq "1" || $sexvio eq "3"){ $vio_checked = $main::parts{'checked'}; }
				$vio_input = qq(<input type="checkbox" name="vio" value="1" id="vio"$vio_checked$main::xclose><label for="vio">15��</label>);
			}

			# 18��
			if($chowold >= 18 || $admin_mode){
			if($sexvio eq "2" || $sexvio eq "3"){ $sex_checked = $main::parts{'checked'}; }
				$sex_input = qq(<input type="checkbox" name="sex" value="1" id="sex"$sex_checked$main::xclose><label for="sex">18��</label>);
			}

			# ���������@�\�̃I��/�I�t
		#	if($thread_key =~ /Not-use-paint/){ }
		#	else{ $use_paint_checked = $main::parts{'checked'}; }
		#my $use_paint_input = qq(<input type="checkbox" name="use_paint" value="1" id="use_paint"$use_paint_checked$main::xclose><label for="use_paint">���G�����@\�\\���g��</label>);

		# �薼�ύX�t�H�[��
		$subject_form = qq(
		<h2 class="bgbcolor"$kstyle_h2>�L���̕ҏW</h2>
		<form action="$script" method="post"$sikibetu>
		<div>
		<input type="hidden" name="mode" value="view"$xclose>
		<input type="hidden" name="moto" value="$realmoto"$xclose>
		<input type="hidden" name="no" value="$in{'no'}"$xclose>
		<input type="hidden" name="r" value="data"$xclose>
		<input type="hidden" name="type" value="subject_edit"$xclose>
		<label for="sub">�薼</label> <input type="text" name="sub" value="$sub" class="subject" id="sub"$xclose>
		$vio_input
		$sex_input
		$use_paint_input
		<input type="submit" value="���̓��e�ŕύX����"$xclose> <span class="guide">*�ύX�����͕ۑ�����܂��B</span>
		</div>
		</form>
		);
	}

# �Ǘ��҂̏ꍇ
if($admin_mode){ $alert = qq(<strong class="red">���Ǘ��҂Ƃ��Đݒ肵�܂��B</strong><br$xclose><br$xclose>); }


	# HTML �i�g�єŁj
	if($kflag){
		$print = qq(
		<h1$kstyle_h1><a href="$topic_url">$sub</a> | �f�[�^</h1>
		$alert
		$line_data
		$subject_form
		$edit_history{'index_line'}
		$tag_line
		$line_support
		$kr_line
		);
	}

	# HTML �i�f�X�N�g�b�v�Łj
	else{
		$print = qq(
		<h1><a href="$topic_url">$sub</a> - �f�[�^</h1>
		$alert
		$line_data
		$subject_form
		$edit_history{'index_line'}
		$tag_line
		$line_support
		$line2_support
		$kr_line
		);
	}

Mebius::BBS->print_html_all($print,{ inline_css => $css_text , BCL => \@BCL , Title => $sub_title });

exit;

}



#-----------------------------------------------------------
# �����ˁI�f�[�^���擾
#-----------------------------------------------------------
sub viewdata_get_support{

my($line,$i,$ii,$allnum,$line2);

# �J�e�S���ݒ��ǂݍ���
my($init_bbs) = Mebius::BBS::init_bbs_parmanent($moto);

# �J�E���g�t�@�C�����J��
open(COUNT_IN,"<","$main::bbs{'data_directory'}_crap_count_${moto}/$in{'no'}_cnt.cgi");
my $top1 = <COUNT_IN>; chomp $top1;
my($count) = split(/<>/,$top1);
if(!$count){ $count = "0"; }
my $top2 = <COUNT_IN>; chomp $top2;

# �������ˁI�f�[�^�̗L�����`�F�b�N
foreach(@support_reason){
$i++;
my($num,$reason) = split(/=/,$_);
foreach ( split(/<>/,$top2) ) {
$ii++;
if($ii == $num && $_) {
$line2 .= qq($reason($_��)\n);
$allnum += $_;
}
}
$ii = 0;
}

# ���f�[�^�����݂���ꍇ
if($line2 ne ""){
$line2 = qq(
<br$xclose><br$xclose>
<div>
<strong>�����ˁI���R (��)�F</strong>
$line2
</div>
);
}

# �f�[�^��W�J
while(<COUNT_IN>){
chomp;
my($key,$handle,$id,$trip,$comment,$account,$host2,$number,$age2,$lasttime,$date2,$res,$deleter) = split(/<>/);

	if($key eq ""){ next; }
	
	if($key eq "0"){
		if($admin_mode){
				my($deleter,$deldate) = split(/>/,$deleter);
				$comment = qq(<span class="del">�폜�ς� by $deleter $deldate�F <del>$comment</del></span>);
		}
		else{ next; }
	}
my $viewname = $handle;
if($trip){ $viewname = "$viewname��$trip"; }
if($account){ $viewname = qq(<a href="${auth_url}$account/">$viewname</a>); }

if($kflag){ $line .= qq(<li>$viewname ��$id &gt; $comment ( $date2 ) - No.$res); }
else{ $line .= qq(<tr><td>$viewname <i>��$id</i></td><td><div class="comment">$comment</div></td><td>$date2</td><td>No.$res); }

if($key ne "0" && $admin_mode){
$line .= qq( ( <a href="$script?mode=view&amp;no=$in{'no'}&amp;r=data&amp;type=support_delete&amp;res=$res">�폜</a> ));
$line .= qq( ( <a href="$script?mode=view&amp;no=$in{'no'}&amp;r=data&amp;type=support_delete&amp;res=$res&amp;penalty=1">���폜</a> ));
}

	# ���e���
	if($admin_mode){
		$line .= qq( / <strong>�Ǘ��ԍ��F <a href="$mainscript?mode=cdl&amp;file=$number&amp;filetype=number" class="red">$number</strong></a>);

			if($main::admy{'master_flag'}){
					if($age2){ $line .= qq( / <strong>�t�`�F <a href="$mainscript?mode=cdl&amp;file=$age2&amp;filetype=agent" class="red">$age2</a></strong>); }
				$line .= qq( / <strong>�z�X�g�F <a href="$mainscript?mode=cdl&amp;file=$host2&amp;filetype=host" class="red">$host2</a></strong>);
			}
	}

if($kflag){ $line .= qq(</li>\n); }
else{ $line .= qq(</td></tr>); }

}
close(COUNT_IN);

	# ���`
	if($line eq ""){ $line = qq(�R�����g�͂܂�����܂���B<br$xclose><br$xclose>); }
	else{

	if($kflag){ $line = qq(<ul>$line</ul>); }
	else{ $line = qq(<table summary="�����ˁI�R�����g">$line</table>); }
	$line .= qq(<span class="guide">���R�����g�ɖ�肪����ꍇ��<a href="http://mb2.jp/_delete/158.html">�폜�˗�</a>�����肢���܂��B</span>);
	}



$line = qq(
<h2 class="support"$kstyle_h2>�����ˁI ($count)</h2>
$line
);

	# �����ˁI�����N
	if($main::device{'level'} >= 2){
		$line .= qq(<span class="guide">���R�����g�������ɂ�<a href="./$in{'no'}.html">�L��</a>�ɖ߂��Ă����ˁI�{�^���������Ă��������B</span> );
	}

my($tag);
if($kflag){ $tag = "k"; } else{ $tag = "p"; }

$line .= qq( <span class="guide">��<a href="/_main/newsupport-$tag-1.html">�����ˁI�R�����g�̈ꗗ</a>������܂��B</span>);

return($line,$line2);

}

#-----------------------------------------------------------
# �^�O���擾
#-----------------------------------------------------------
sub viewdata_get_tags{

# �Ǐ���
my($key,$sub) = @_;
my($line,$action,$type);
our($selfurl_enc);

# ���^�[��
if(!$alocal_mode && ($secret_mode || $test_mode)){ return; }

# CSS��`
$css_text .= qq(.tagform{margin:1em 0em;});

# �^�C�v��`
if($in{'k'}){ $type = " MOBILE"; }

# �^�O�L���t�@�C�����J��
require "${int_dir}main_tag.pl";
my($flag,$hit,$tag_line,$tagnum,$tagkey) =  &open_threadtag("VIEW FORM","","",$moto,$in{'no'});

# �J�e�S���ݒ����荞��
my($init_bbs) = Mebius::BBS::init_bbs_parmanent($moto);

# �^�O���Ȃ��ꍇ
if($line eq ""){ $line = qq(�^�O�͂܂�����܂���B); }

# �^�O�̕\��
$line = qq(
<h2 class="tag" id="TAG"$kstyle_h2>�^�O</h2>
<div class="tags">$tag_line</div>
);

# ���M����`
$action = $main_url;

# �^�O�o�^�t�H�[��
if($key eq "1" || $key eq "2" || $key eq "3" || $key eq "5" || $admin_mode){

# ���O�C�����Ă���ꍇ
if($idcheck || $adminmode || $main::device{'level'} >= 2){
$line .= qq(
<form action="$action" method="post" class="tagform"$sikibetu>
<div>
<input type="hidden" name="mode" value="tag-make"$xclose>
<input type="hidden" name="bbs-no" value="$moto-$in{'no'}"$xclose>
<input type="text" name="tagname" value=""$xclose>
<input type="submit" value="���̃^�O����o�^����"$xclose>
 ( <a href="/_main/newtag-p-1.html">���V���^�O</a> )
</div>
</form>
);

if($kflag){ $line .= qq(<div style="font-size:small;">); }

$line .= qq(
<span class="guide">���u$sub�v�Ɋ֘A����L�[���[�h�i�P��j��o�^���Ă��������B���Ƃ���<strong>�u�_���̋L���v</strong>�ł����<strong>�u�����v�u�Q�Z�v</strong>�Ȃǂ̒P���o�^���܂��B </span><br$xclose>
<span class="alert">���A�J�E���g / �ڑ��f�[�^ ( <a href="${auth_url}$pmfile/">$pmfile</a> / $addr ) �͋L�^����܂��B���֌W�ȃ^�O�̓o�^�A�����点�o�^�A���f�ȓo�^�Ȃǂ͂��������������B\( <a href="http://mb2.jp/_delete/158.html">�폜�˗��͂�����܂ŁAURL�ƃ^�O����</a> \)</span>
);

if($kflag){ $line .= qq(</div>); }

}
# ���O�C�����Ă��Ȃ��ꍇ
else{
my($backurl) = "http://$server_domain/_$moto/$in{'no'}_data.html#TAG";
my($backurl_enc) = Mebius::Encode("",$backurl);
$line .= qq(<br$xclose><div>�^�O��o�^����ɂ�<a href="${auth_url}?backurl=$selfurl_enc">�A�J�E���g�Ƀ��O�C���i�܂��͐V�K�o�^�j</a>���Ă��������B</div>);
}

}

return($line);

}


use strict;

#-----------------------------------------------------------
# �L���̕ύX
#-----------------------------------------------------------
sub viewdata_subject_edit{

# �Ǐ���
my($type,$moto,$thread_number) = @_;
my($line,$line_index,$line_backup,$i,$filehandle2,$index_sexvio,$thread_handler);
my(%renew_thread,$allow_edit_flag,$edit_history_text);
our($admin_mode,%in);

# �A�N�Z�X����
main::axscheck("Post-only");

# �o�b�N�A�b�v�̍ő�s��
my $max = 100;

# �e��G���[
if(($in{'sub'} =~ /^(\x81\x40|\s)+$/)||($in{'sub'} eq "")) { &error("�薼������܂���B"); }
if($in{'sub'} =~ /(<br>|&shy|&nbsp)/) { &error("�薼�ɋ󔒗v�f������܂��B"); }
if(length($in{'sub'}) > 25*2 && !$admin_mode) { &error("�薼���������܂��B"); }

# �A�����M���֎~
Mebius::Redun(undef,"Thread-edit",15);

# �L���ǂݍ���
my(%thread) = Mebius::BBS::thread({},$moto,$thread_number);

	# �L�[����
	if(!$thread{'mythread_flag'} && !$admin_mode){ main::error("�����̋L���ł͂Ȃ����߁A�ҏW�ł��܂���B"); }
	if($thread{'keylevel'} < 1 && !$admin_mode){ &error("�ߋ����O�A���b�N�L���A�폜�ς݋L���̃^�C�g���͕ύX�ł��܂���B"); }

	# 15��/18�փ`�F�b�N��Ԃ�ύX
	if($in{'vio'} && $in{'sex'}){
		$renew_thread{'sexvio'} = 3;
		$index_sexvio = 9;
	}
	elsif($in{'vio'}){
		$renew_thread{'sexvio'} = 1;
		$index_sexvio = 8;

	}
	elsif($in{'sex'}){
		$renew_thread{'sexvio'} = 2;
	}
	else{
		$renew_thread{'sexvio'} = "";
		$index_sexvio = 1;
	}

	# �ύX�`�F�b�N
	if($thread{'sexvio'} ne $renew_thread{'sexvio'}){
			if($renew_thread{'sexvio'} eq "3" || $renew_thread{'sexvio'} eq "2"){ $edit_history_text .= qq(18�֏�Ԃɂ��܂����B); }
			elsif($renew_thread{'sexvio'} eq "1"){ $edit_history_text .= qq(15�֏�Ԃɂ��܂����B); }
			else{ $edit_history_text .= qq(18��/15�փ`�F�b�N���������܂���); }
		$allow_edit_flag = 1;
	}

	#if(Mebius::Fillter::basic(u$in{'sub'}))

	# �V�����薼
	$renew_thread{'sub'} = $in{'sub'};
	if($thread{'subject'} ne $renew_thread{'sub'}){
		$allow_edit_flag = 1;
		$edit_history_text .= qq(�薼�� �y$renew_thread{'sub'}�z �ɕύX���܂����B);
	}

	# ���G�����@�\�̃I��/�I�t��ύX
	#$thread{'concept'} =~ s/ Not-use-paint//g;
	#if($in{'use_paint'}){ }
	#else{ $renew_thread{'concept'} = qq($thread{'concept'} Not-use-paint); }

	# ���b�N�J�n
	if($allow_edit_flag){
		main::lock($moto);
	}

	# �X���b�h�X�V
	if($allow_edit_flag){
		Mebius::BBS::thread({ Renew => 1 , select_renew => \%renew_thread },$moto,$thread_number);
	}

	# �C���f�b�N�X���X�V
	if($allow_edit_flag){
		open($filehandle2,"+<$main::nowfile") || &error("�C���f�b�N�X���J���܂���B");
		flock($filehandle2,2);
		my $top_index = <$filehandle2>;
		$line_index .= $top_index;
			while(<$filehandle2>){
				chomp;
				my($no,$sub,$res,$name,$date,$lastname,$key) = split(/<>/);
				if($no eq $thread_number){
					$sub = $renew_thread{'sub'};
					$key = $index_sexvio;
				}
				$line_index .= qq($no<>$sub<>$res<>$name<>$date<>$lastname<>$key<>\n);
			}
		seek($filehandle2,0,0);
		truncate($filehandle2,tell($filehandle2));
		print $filehandle2 $line_index;

		close($filehandle2);

		# �p�[�~�b�V�����X�V
		Mebius::Chmod(undef,$main::nowfile)
	}


	# �o�b�N�A�b�v���X�V
	if($allow_edit_flag){
		Mebius::Fileout(undef,"${main::int_dir}_backup/subedit_backup.cgi",$line_backup);
	}

	# ���b�N����
	if($allow_edit_flag){
		main::unlock($moto);
	}

	# �ҏW�������X�V
	if($allow_edit_flag){
		Mebius::BBS::ThreadEditHistory("Renew New-edit",$moto,$thread_number,$edit_history_text);
	}

	# ���_�C���N�g
	Mebius::Redirect("",$main::data_url);

exit;

}


#-----------------------------------------------------------
# �����ˁI�R�����g�̍폜
#-----------------------------------------------------------
sub viewdata_support_delete{

# �Ǐ���
my($type,$moto,$thread_number) = @_;
my(@line,$flag,$top2_flag);

	# �e��G���[
	if($moto =~ /\W/){ main::error("�f���̎w�肪����������܂���B"); }
	if($thread_number =~ /\D/){ main::error("�L���ԍ��̎w�肪����������܂���B"); }
	if(!$main::admin_mode){ &error("�y�[�W�����݂��܂���B"); }

# ���b�N�J�n
main::lock("$thread_number");

# �J�E���g�t�@�C�����J��
open(COUNT_IN,"<$main::bbs{'data_directory'}_crap_count_${moto}/${thread_number}_cnt.cgi");

my $top1 = <COUNT_IN>; chomp $top1;
my $top2 = <COUNT_IN>; chomp $top2;

	# �t�@�C����W�J
	while(<COUNT_IN>){

		# �s�𕪉�
		chomp;
		my($key,$handle,$id,$trip,$comment,$account2,$host2,$number2,$age2,$lasttime,$date2,$res,$deleter) = split(/<>/);
		if($key ne "0" && $res eq $main::in{'res'}){

				# �y�i���e�B��^����ꍇ
				if($main::in{'penalty'}){
					Mebius::penalty_file("Cnumber Renew Penalty",$number2,"�h$main::sub�h�̃f�[�^",$comment,"/_$moto/${thread_number}_data.html");
					Mebius::penalty_file("Account Renew Penalty",$account2,"�h$main::sub�h�̃f�[�^",$comment,"/_$moto/${thread_number}_data.html");
					Mebius::penalty_file("Host Renew Penalty",$host2,"�h$main::sub�h�̃f�[�^",$comment,"/_$moto/${thread_number}_data.html");
				}

			$key = 0;
			$deleter = "$main::admy_name>$main::date";
			$flag = 1;
		}
		push(@line,"$key<>$handle<>$id<>$trip<>$comment<>$account2<>$host2<>$number2<>$age2<>$lasttime<>$date2<>$res<>$deleter<>\n");
	}
close(COUNT_IN);

# �g�b�v�f�[�^
unshift(@line,"$top2\n");
unshift(@line,"$top1\n");

# ���e���Ȃ��ꍇ
if(!$flag){ &error("�폜������e������܂���B"); }

# �J�E���g�t�@�C�����X�V
Mebius::Fileout(undef,"$main::bbs{'data_directory'}_crap_count_${moto}/${thread_number}_cnt.cgi",@line);

# ���b�N����
main::unlock("$thread_number");

# ���_�C���N�g
Mebius::Redirect("","$main::data_url");

exit;
}

use strict;
package Mebius::BBS;

#-----------------------------------------------------------
# �L���̕ύX����
#-----------------------------------------------------------
sub ThreadEditHistory{

# ����
my($type,$realmoto,$thread_number) = @_;
my(undef,undef,undef,$new_text,$new_handle) = @_ if($type =~ /New-edit/);
my($edit_handler,@renew_line,%edit,$i,$index_line);

# �����`�F�b�N
if($realmoto eq "" || $realmoto =~ /\W/){ return(); }
if($thread_number eq "" || $thread_number =~ /\D/){ return(); }

# �t�@�C��/�f�B���N�g����`
my $directory1 = "$main::bbs{'data_directory'}_thread_edit_history_${realmoto}/";
my $file = "${directory1}${thread_number}_thread_edit.log";

# �t�@�C�����J��
open($edit_handler,"<$file");

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($edit_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$edit_handler>);
($edit{'key'}) = split(/<>/,$top1);

	# �V�K�ҏW�̏ꍇ�A���E���h�J�E���^�𑝂₷
	if($type =~ /New-edit/){
		$i++;
	}

	# �t�@�C����W�J
	while(<$edit_handler>){

		# ���E���h�J�E���^
		$i++;

		# ���̍s�𕪉�
		chomp;
		my($key2,$text2,$account2,$handle2,$cnumber2,$encid2,$host2,$lasttime2,$date2) = split(/<>/);

			# �t�@�C���X�V�p
			if($type =~ /Renew/ && $i <= 5){
				push(@renew_line,"$key2<>$text2<>$account2<>$handle2<>$cnumber2<>$encid2<>$host2<>$lasttime2<>$date2<>\n");
			}

			# �C���f�b�N�X�擾�p
			if($type =~ /Get-index/){
				$index_line .= qq(<div class="line-height">\n);
				$index_line .= qq($text2\n);
				$index_line .= qq( ( $date2 ) );
				$index_line .= qq( �b �ҏW�� - );

					if($account2){ $index_line .= qq(<a href="${main::auth_url}$account2/">\@$account2</a>\n); }
					if($encid2){ $index_line .= qq( <i>��$encid2</i>); }
				$index_line .= qq(</div>\n);
			}

	}

	# �V�K�ҏW
	if($type =~ /New-edit/){
		my($encid) = main::id();
		unshift(@renew_line,"<>$new_text<>$main::myaccount{'file'}<>$new_handle<>$main::cnumber<>$encid<>$main::host<>$main::time<>$main::date<>\n");
	}


close($edit_handler);

	# �t�@�C���X�V
	if($type =~ /Renew/){
		unshift(@renew_line,"$edit{'key'}<>\n");
		Mebius::Mkdir(undef,$directory1);
		Mebius::Fileout(undef,$file,@renew_line);
	}

	# �C���f�b�N�X���`
	if($type =~ /Get-index/){
		$edit{'index_line'} .= qq(<div><h3$main::kstyle_h3>�ύX����</h3>);
		$edit{'index_line'} .= qq($index_line);
		$edit{'index_line'} .= qq(</div>);

	}


return(%edit);

}

1;
