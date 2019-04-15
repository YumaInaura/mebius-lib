
package main;

use Mebius::BBS;
use Mebius::History;
use Mebius::BBS::Index;
use Mebius::Penalty;

#-----------------------------------------------------------
# �L������
#-----------------------------------------------------------
sub bbs_memo{

# �錾
our($mode,$css_text,$ngbr,$memo_wait,$memo_author_wait,$memo_maxmsg,$memo_history_max);
our(%in,$i_com,$i_nam,$sub_title);

# �ő啶�����A�҂����ԂȂǐݒ�
$ngbr = 200;
$memo_wait = 15;
$memo_author_wait = 5;
$memo_maxmsg = 5000;
$memo_history_max = 1000;

# �t�@�C����`
local $file = $in{'no'};
$file =~ s/\D//g;
if($file eq ""){ &error("�L�����w�肵�Ă��������B"); }

# �ϐ���`
$i_nam = $in{'name'};
$i_com = $in{'comment'};

# �g�у��[�h
if($mode eq "kview"){ &kget_items(); }

# �^�C�g���A�㕔���j���[��`
$sub_title = "����";
$head_link4 = qq(&gt; ����);

	# ���[�h�U�蕪��
	if($in{'type'} eq "action"){ &memo_write("",$file); }
	elsif($in{'type'} eq "delete" && $admin_mode){ &memo_delete_history(); }
	elsif($in{'type'} eq "oview"){ &memo_oview($memo_body); }
	elsif($in{'type'} eq ""){ &memo_view("VIEW",$file); }
	else{ &error("�����^�C�v��I��ł��������B"); }

}

#-----------------------------------------------------------
# �L�������̕\���A�ҏW�t�H�[�� - �������[�v���ӁI
# �T�u���[�`������ &memo_error; �̏�����u���Ȃ�
#-----------------------------------------------------------
sub memo_view{

# �Ǐ���
my($type,$file,$error_message) = @_;
my(%th,$intextarea,$history_line,$guide_line,$preview_line,$waittime,$waitmin,$name_input,$namevalue,%memo_history);
our(%in,$moto,$noindex_flag,$mode,$script,$memo_view_done);

# �G���[���A�����b�N
if($lockflag) { &unlock($lockflag); }

# ��d�������֎~
if($memo_view_done){ &error("��d�����͏o���܂���B"); }
$memo_view_done = 1;

# �t�@�C����`
$file =~ s/\D//g;
if($file eq ""){ &error("�L�����w�肵�Ă��������B"); }

# ���L���̃g�b�v�f�[�^���擾
(%th) = Mebius::BBS::thread({},$moto,$file);

# �폜�ς݋L���A�Ǘ��҂̋L���A���݂��Ȃ��L���A�ߋ����O�́A������\���E�ҏW�ł��Ȃ��悤��
if($th{'key'} eq "4" || $th{'key'} eq "3" ||  $th{'key'} eq "6" || $th{'key'} eq ""){ &error("�����̋L���̃����͕ҏW�ł��܂���B<br>"); }

# �^�C�g����`
$head_link3 = qq(&gt; <a href="${file}.html">$th{'sub'}</a>);
$sub_title = qq(���� | $th{'sub'});

# CSS��`
$css_text .= qq(
div.preview{padding:1.0em;line-height:1.4;border:solid 1px #00f;margin:1.0em 0.0em;}
div.error{padding:1.0em;line-height:1.4;border:solid 1px #f00;margin:1.0em 0.0em;color:#f00;}
ul{font-size:90%;}
li{line-height:1.5;}
i{font-size:70%;}
div.after{background-color:#dee;border:solid 1px #000;margin:0em 0em 1em 0em;width:47%;float:left;padding:0.5em;}
div.before{background-color:#ddd;border:solid 1px #000;margin:0em 0em 1em 0em;width:47%;float:right;padding:0.5em;}
div.after_text{padding:1em;word-wrap:break-word;overflow:hidden;line-height:1.4;}
div.before_text{padding:1em;word-wrap:break-word;overflow:hidden;line-height:1.4;}
div.after_title{padding:0.5em 0em 0em 0.5em;}
div.before_title{padding:0.5em 0em 0em 0.5em;}
hr.none{display:none;}
h2{background-color:#fda;border:solid 1px #000;padding:0.2em 0.4em;font-size:120%;}
h3{clear:both;}
h4{display:inline;}
strong.blue{color:#00f;}
textarea.memoarea{width:99%;height:300px;}
input.name{width:14em;}
div.clear{clear:both;}
);

# �L���b�V�������Ȃ�
$noindex_flag = 1;

# �e�L�X�g�G���A�p�ɕϊ�
if($type =~ /ERROR/){ $intextarea = $in{'comment'}; }
else{ $intextarea = $th{'memo_body'}; }
$intextarea =~ s/<br>/\n/g;
if($type =~ /VIEW/){ $intextarea =~ s/No\.([0-9]+)/&gt;&gt;$1/g; }

	# �������擾
	#if($type =~ /VIEW/ && $mode ne "kview"){ ($history_line) = &get_memo_history(); }
	if($type =~ /VIEW/ && $mode ne "kview"){

		(%memo_history) = &bbs_memo_history("Get-index",$main::moto,$file);


				if($main::admin_mode){

					# �t�H�[��
					$history_line .= qq(<form action="" method="post"><div>);
					$history_line .= qq(<input type="hidden" name="mode" value="memo"$main::xclose>);
					$history_line .= qq(<input type="hidden" name="type" value="delete"$main::xclose>);
					$history_line .= qq(<input type="hidden" name="moto" value="$realmoto"$main::xclose>);
					$history_line .= qq(<input type="hidden" name="no" value="$main::in{'no'}"$main::xclose>);
					$history_line .= qq($memo_history{'index_line'});
					$history_line .= qq(<input type="submit" value="���s����"$main::xclose>);
					$history_line .= qq(</form></div>);

				}

				else{
					$history_line = $memo_history{'index_line'};
				}

		# �Â�����	
		#($history_line) = &get_memo_history();

	}

	# �L�������̃K�C�h��\��
	if($type =~ /VIEW/){
		$guide_line = qq(
		<h2 id="RULE">���[��</h2>
		<ul>
		<li><strong class="red">�u�ォ�猈�܂����L�����[���v�u���ӏ����v�u��܂��ȋL���̗���i�܂Ƃ߁j�v�u�p���`�v�u�֘A�t�q�k�v</strong>�ȂǁA�L���i�s�Ɋւ��ă���������Ă��������B�G�k��A�l�I�Ȃ����̏ꏊ�ł͂���܂���B</li>
		<li>�N�ł��{���E�ҏW�ł��鋤�L�̃����ł��B��{�I��<strong class="red">�O�̓��e�͏������A���͂�ǉ�������A�ҏW���邾���ɂ��Ă��������B</strong>�i�O�̃����������āA���������̃��������̂́A�Ԉ�����g�����ł��j</li>
		<li>�������e�͕ύX����邱�Ƃ�����̂ŁA�厖�ȏ���<a href="${guide_url}%A5%ED%A5%B0%CA%DD%C2%B8">���O�ۑ�</a>���邩�A<a href="http://aurasoul.mb2.jp/_qst/2341.html">�����u����</a>�𗘗p���Ă��������B�i�����Ԃ� <a href="#HISTORY">������</a> �ɕۑ�����܂��j�B</li>
		<li>���A�ڂ������[����<a href="${guide_url}%B5%AD%BB%F6%A5%E1%A5%E2">�����̃K�C�h���C��</a>���������������B</li>
		$last_man
		</ul>
		);
	}

	# �G���[�\��
	if($e_com || $error_message){
		$error_line = qq(
		<div class="error"> �G���[�F
		<br$xclose><br$xclose> $error_message $e_access $e_sub $e_com</div>
	);
	}

	# �v���r���[�\��
	if($type =~ /ERROR/){
		$prev_text = $i_com;
		$prev_text = &memo_auto_link($prev_text);
		if($mode eq "kview"){ $prev_text =~ s/<br>/<br$xclose>/g; }
		$preview_line = qq(
		<div class="preview">
		<strong class="blue">�v���r���[���ł��B�܂��������܂�Ă��܂���B</strong><br$xclose><br$xclose>
		$prev_text</div>
		);
	}


# �`���[�W���Ԕ���
($chargetime,$chargemin,$chargesec) = &get_memo_chargetime();

	# �M����
	if($in{'name'}){ $namevalue = $in{'name'}; } else { $namevalue = $cnam; }
	if($admin_mode){
		$name_input = qq(�M��: <input type="text" name="name" value="$my_name" class="name"$disabled$xclose><br$xclose><br$xclose>);
	}
	else{
		$name_input = qq(�M��: <input type="text" name="name" value="$namevalue" class="name"$xclose>);
			if($chargetime > 0){ $name_input .= qq(�@<strong class="red">���`���[�W���Ԓ��ł��B�i�c��$chargemin��$chargesec�b�j</strong><br$xclose><br$xclose>); }
	}

# �g�s�l�k
$print .= qq(
<h1><a href="${file}.html">$th{'sub'}</a> �̃���</h1>
$guide_line
$error_line
$preview_line
<h2 id="EDIT">�ҏW</h2>
<form action="$script" method="post"$sikibetu>
<div>
<input type="hidden" name="mode" value="$mode"$xclose>
<input type="hidden" name="moto" value="$realmoto"$xclose>
<input type="hidden" name="no" value="$file"$xclose>
<input type="hidden" name="r" value="memo"$xclose>
<input type="hidden" name="type" value="action"$xclose>
$name_input
<textarea name="comment" cols="25" rows="5" class="memoarea">$intextarea</textarea><br$xclose>
<input type="submit" name="preview" value="���̓��e�Ńv���r���[����" class="ipreview"$xclose>
<input type="submit" value="���̓��e�ő��M����" class="isubmit"$xclose>
);

# ����
$print .= qq(<input type="hidden" name="up" value="$cup"$xclose>);

# �t�H�[���I���
$print .=  qq(
<br$xclose><br$xclose>
<ul>
<li><strong class="red">�ڑ��f�[�^ ( $addr ) �͕ۑ�����܂��B�u�l���f�ځv�u�r�炵�v�u�l�|�A�A���v�Ȃǂ̃��[���ᔽ�͋֎~�ł��B</strong></li>
<li>�s���������ƌ��̋L���ŏȗ�����܂��B�s���� // �i���p�X���b�V���Q�j�ɂ���ƁA���L���ŃR�����g�A�E�g�i��\\���j�ɂ��邱�Ƃ��o���܂��B</li>
</ul>
</div></form>
<h2 id="HISTORY">����</h2>
$history_line
<div class="clear"></div>
);



# �o��
Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#--------------------------------------------------
# �L�������̃G���[�E�v���r���[
#--------------------------------------------------
sub memo_error{
my($message,$file,$error) = @_;
our(%in);
&memo_view("ERROR",$in{'no'},$message);
}

#-----------------------------------------------------------
# �L�������̒��g������\��
#-----------------------------------------------------------
sub memo_oview{

# �Ǐ���
my($print);
our(%th,%in,$moto);

# ���L���̃g�b�v�f�[�^���擾
(%th) = Mebius::BBS::thread({},$moto,$in{'no'});

# ���������N
($memo_text) = &memo_auto_link($th{'memo_body'});

	# �g�їp����
	if($kflag){
		$memo_text =~ s/<br>/<br$xclose>/g;
		$print .= qq(<a href="$in{'no'}.html">��</a>$kboad_link$kindex_link);
	}

# �g�s�l�k
$print .= qq(
<hr$xclose>���� ( <a href="${file}.html">$th{'sub'}</a> ) <hr$xclose>
$memo_text
<br$xclose>
);

# �ҏW�����N
if($main::device{'level'} >= 1){ $print .= qq(\(<a href="$script?mode=kview&amp;no=$in{'no'}&amp;r=memo" rel="nofollow">���ҏW����</a>\)); }

Mebius::Template::gzip_and_print_all({},$print);


exit;

}


use strict;

#-----------------------------------------------------------
# �L�������̍��� (�V / �L���P��)
#-----------------------------------------------------------
sub bbs_memo_history{

# �錾
my($type,$moto,$thread_number) = @_;
my(undef,undef,undef,$renew_new_line) = @_ if($type =~ /New-line/);
my(undef,undef,undef,%query) = @_ if($type =~ /Delete-line/);
my($new_before_text,$new_after_text,$new_handle,$new_encid,$new_enctrip) = split(/<>/,$renew_new_line) if($type =~ /New-line/);
my($i,@renew_line,%data,$file_handler,$hit_index);

	# �����`�F�b�N
	if($moto =~ /\W/ || $moto eq ""){ return(); }
	if($thread_number =~ /\D/ || $thread_number eq ""){ return(); }

# �t�@�C����`
my($base_directory_per_bbs) = Mebius::BBS::base_directory_path_per_bbs($moto);
	if(!$base_directory_per_bbs){
		return();
	}

#my $directory1 = "${main::int_dir}_bbs_memo_history/";
my $directory1 = "${base_directory_per_bbs}_memo/";
my $file1 = "${directory1}${thread_number}_memo_history.log";

# �ő�s���`
my $max_line = 100;
my $max_view_line = 10;

# �e�����̍ő�ۑ����� ( �P�s����)
my $historty_max_save_time = 30*24*60*60;

	# �t�@�C�����J��
	if($type =~ /File-check-error/){
		open($file_handler,"<$file1") || main::error("�t�@�C�������݂��܂���B");
	}
	else{
		open($file_handler,"<$file1") && ($data{'f'} = 1);
	}

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($file_handler,1); }

# �g�b�v�f�[�^�𕪉�
chomp(my $top1 = <$file_handler>);
($data{'key'},$data{'number_of_posts'}) = split(/<>/,$top1);

	# �t�@�C����W�J
	while(<$file_handler>){

		# ���E���h�J�E���^
		$i++;
		
		# ���̍s�𕪉�
		chomp;
		my($key2,$line_number2,$before_text2,$after_text2,$lasttime2,$handle2,$encid2,$enctrip2,$host2,$agent2,$cnumber2,$account2) = split(/<>/);

			# ���C���f�b�N�X�\���p ---
			if($type =~ /Get-index/){

				# �Ǐ���
				my($before_text_line2,$after_text_line2,$view_cnumber,$view_account,$deleted_flag,$delete_input,$deleted_flag);

					# �폜�ς݂̍s
					if($key2 =~ /Deleted-line/){

						# �t���O�𗧂Ă�
						$deleted_flag = 1;

							if($main::admin_mode){

							}
							else{
								next;
							}
					}


					# ���t���v�Z
					my($date2) = Mebius::Getdate(undef,$lasttime2);
					my($how_before_edited) = Mebius::SplitTime("Color-view Plus-text-�O Get-top-unit",$main::time-$lasttime2);

					# �������΂��ꍇ
					if($key2 =~ /Deleted-line/){ $deleted_flag = 1; }
					if($deleted_flag && !$main::admin_mode){ next; }
					if($main::time > $lasttime2 + $historty_max_save_time){ next; }

				# �q�b�g�J�E���^
				$hit_index++;

					# �\���ő吔�ɒB�����ꍇ
					if($hit_index > $max_view_line){ next; }

					# ��������F�Â��i�ǉ��� - �A�t�^�[)
					foreach (split/<br>/,$after_text2){

							if($_ eq ""){ $after_text_line2 .= qq(<br>); next; }

						my($text1) = $_;
						my($flag1);

							# �r�t�H�[�e�L�X�g�Ɣ�r
							foreach(split/<br>/,$before_text2){
									if($_ eq $text1){ $flag1 = 1; }
							}

							if(!$flag1){ $text1 = qq(<strong class="red">$text1</strong>); }
						$after_text_line2 .= qq($text1<br>);

						# �I�[�g�����N
						($after_text_line2) = &memo_auto_link($after_text_line2);

					}


					# ��������F�Â��i�r�t�H�[�j
					foreach(split/<br>/,$before_text2){

							if($_ eq ""){ $before_text_line2 .= qq(<br>); next; }

						my($text2) = $_;
						my($flag2);

							# �A�t�^�[�e�L�X�g�Ɣ�r
							foreach(split/<br>/,$after_text2){
									if($_ eq $text2){ $flag2 = 1; }
							}
	
							if(!$flag2){ $text2 = qq(<strong class="blue">$text2</strong>); }
						$before_text_line2 .= qq($text2<br>);
						($before_text_line2) = &memo_auto_link($before_text_line2);



					}

					# �\������
					if($lasttime2 <= 1321451532){} # 2011/11/16 (��) �g���b�v�̌������̂܂ܕ\������Ă��܂��Ă����s��ɑΉ�
					elsif($enctrip2){ $handle2 = qq($handle2��$enctrip2); }
					

					if($account2){ $view_account = qq(<a href="${main::auth_url}$account2/">\@$account2</a>); }
					if($main::admin_mode){ $view_cnumber = qq(<a href="$main::mainscript?mode=cdl&amp;file=$cnumber2&amp;filetype=number" class="red">$cnumber2</a>); }


				# �폜�����N
				if($main::admin_mode && !$deleted_flag){

						# �폜�ς݂̏ꍇ
						if($deleted_flag){ $after_text_line2 = qq(<span class="red"></span>); }
						# �폜����Ă��Ȃ��ꍇ
						else{
							my($checked_none);
							$checked_none = $main::parts{'checked'};

							$delete_input .= qq(<input type="radio" name="line_$line_number2" value="none" id="line_${line_number2}_none"$checked_none>);
							$delete_input .= qq(<label for="line_${line_number2}_none">���I��</label>\n);
							$delete_input .= qq(<input type="radio" name="line_$line_number2" value="delete" id="line_${line_number2}_delete">);
							$delete_input .= qq(<label for="line_${line_number2}_delete">�폜</label>\n);
							$delete_input .= qq(<input type="radio" name="line_$line_number2" value="penalty" id="line_${line_number2}_penalty">);
							$delete_input .= qq(<label for="line_${line_number2}_penalty" class="red">���폜</label>\n);
						}
						# ���`
						if($delete_input){ $delete_input = qq(<div class="right margin">$delete_input</div>); }
				}

				# �A�t�^�[���`
				$after_text_line2 = qq(<h3>$line_number2��ڂ̕ҏW - $handle2 $view_account<i>��$encid2</i> $view_cnumber</h3><div class="after"><div class="after_title"><h4>���A�t�^�[ </h4></div><div class="after_text">$after_text_line2</div><div class="right">�ҏW�F $how_before_edited ( $date2 ) No.$line_number2</div>$delete_input</div>);

				# �r�t�H�[���`
				$before_text_line2 = qq(<div class="before"><div class="before_title"><h4>���r�t�H�[</h4></div><div class="before_text">$before_text_line2</div></div>\n);

				$data{'index_line'} .= qq($after_text_line2$before_text_line2);

			}

			# ���s�폜�p
			if($type =~ /Delete-line/){

					# ���ʂ̍폜
					if($main::in{"line_$line_number2"} eq "delete" || $main::in{"line_$line_number2"} eq "penalty"){
						$key2 =~ s/(\s)?Deleted-line//g;
						$key2 .= qq( Deleted-line);
					}

					# �y�i���e�B�폜
					if($main::in{"line_$line_number2"} eq "penalty" && $key2 !~ /Penalty-done/){
						$key2 =~ s/(\s)?Penalty-done//g;
						$key2 .= qq( Penalty-done);
							if($cnumber2){ Mebius::penalty_file("Cnumber Renew Penalty",$cnumber2); }
							if($host2){ Mebius::penalty_file("Host Renew Penalty",$host2); }
							if($agent2 && $cnumber2 eq ""){ Mebius::penalty_file("Agent Renew Penalty",$agent2); }
							if($account2){ Mebius::penalty_file("Account Renew Penalty",$account2); }
					}

			}

			# ���t�@�C���X�V�p
			if($type =~ /Renew/){

					# �ő�s���ɒB�����ꍇ
					if($i > $max_line){ next; }

					# ������x�ȏ�A�Â��s�͎����폜
					if($main::time > $lasttime2 + $historty_max_save_time){ next; }

				# �s��ǉ�
			push(@renew_line,"$key2<>$line_number2<>$before_text2<>$after_text2<>$lasttime2<>$handle2<>$encid2<>$enctrip2<>$host2<>$agent2<>$cnumber2<>$account2<>\n");

			}


	}

close($file_handler);


	# �V�����s��ǉ�
	if($type =~ /New-line/){

		$data{'number_of_posts'}++;

	unshift(@renew_line,"<>$data{'number_of_posts'}<>$new_before_text<>$new_after_text<>$main::time<>$new_handle<>$new_encid<>$new_enctrip<>$main::host<>$main::agent<>$main::cnumber<>$main::myaccount{'file'}<>\n");

	}

	# �C���f�b�N�X�擾�p ���`
	if($type =~ /Get-index/){

	}


	# �t�@�C���X�V
	if($type =~ /Renew/){

		# �f�B���N�g���쐬
		Mebius::Mkdir(undef,$directory1);
		#Mebius::Mkdir(undef,$directory2);

		# �g�b�v�f�[�^��ǉ�
		unshift(@renew_line,"$data{'key'}<>$data{'number_of_posts'}<>\n");

		# �t�@�C���X�V
		Mebius::Fileout(undef,$file1,@renew_line);

	}

return(%data);

}



#-------------------------------------------------
# ���������N����
#-------------------------------------------------
sub memo_auto_link {

# �錾
my($msg) = @_;
our(%in,$kflag);

($msg) = Mebius::auto_link($msg);


if($kflag){ $msg =~ s/No\.([0-9]{1,5})(([,-])([0-9,]+)||$)/<a href=\"$in{'no'}.html-$1$2#RES\">#$1$2<\/a>/g; }
else{ $msg =~ s/No\.([0-9]{1,5})(([,-])([0-9,]+)||$)/<a href=\"$in{'no'}.html-$1$2#RES\">&gt;&gt;$1$2<\/a>/g; }


return($msg);
}

#--------------------------------------------------
# �L����������������
#--------------------------------------------------
sub memo_write{

# �錾
my($type,$thread_number) = @_;
my($line,$enctrip,$i_handle,$i_com,$chargetime,$chargemin,$chargesec);
my($backup_line,$put_agent,$file_handle1,%renew_thread);
our(%in,$moto,$int_dir,$log_dir,$moto,$head_link3,$head_link4,$head_link5,$admy_name,$date,$host);
my($share_directory) = Mebius::share_directory_path();
my $penalty = new Mebius::Penalty;

	# �����`�F�b�N
	if($thread_number eq "" || $thread_number =~/\D/){ main::error("�L�����w�肵�Ă��������B"); }

# ���L���̃g�b�v�f�[�^���擾
my(%th) = Mebius::BBS::thread({},$moto,$in{'no'});
	if($th{'key'} eq "4" || $th{'key'} eq "3" ||  $th{'key'} eq "6" || $th{'key'} eq ""){
		$main::e_com .= qq(�����̋L���̃����͕ҏW�ł��܂���B<br>);
	}

# �^�C�g����`
$head_link3 = qq(&gt; <a href="${thread_number}.html">$th{'sub'}</a>);
$head_link4 = qq(&gt; <a href="${thread_number}_memo.html">����</a>);
$head_link5 = qq(&gt; �ҏW);

	# �f�������e��~���[�h�̏ꍇ
	if(Mebius::Switch::stop_bbs()){ main::error("�f���S�̂ŁA�X�V���~���ł��B"); }

# �A�N�Z�X����,�h�c�t�^�A�g���b�v�t�^
if(!$main::admin_mode){ &axscheck(); }
our($encid) = &id();
($enctrip,$i_handle) = &trip($in{'name'});

my$isp_data = $penalty->my_isp_data();
	if($isp_data->{'must_compare_xip_flag'}){
		main::error("�������X�V�ł��܂���B");
	}

# �e��G���[
if($main::admin_mode){ $i_handle = $admy_name; }
if($th{'memo_body'} eq $in{'comment'}){ $main::e_com .= "�����e���ς���Ă��܂���B<br>"; }
if(!$main::admin_mode){ &memo_base_error_check(); }

# �`���[�W����
($chargetime,$chargemin,$chargesec) = &get_memo_chargetime();
if($chargetime > 0 && !$main::alocal_mode){ $main::e_com .= qq(���`���[�W���Ԓ��ł��B����$chargemin��$chargesec�b�҂��Ă��������B<br>); }

# �R�����g���`
$i_com = $in{'comment'};
$i_com =~ s/&gt;&gt;([0-9]+)/No\.$1/g;
if($main::admin_mode){ ($i_com) = Mebius::Fixurl("Admin-to-normal",$i_com); }

	# ���݂��Ȃ����X�Ԃ��C��
	#if(!$main::admin_mode){ ($i_com) = &checkres_number($i_com,$th{'res'}); }
	($i_com) = Mebius::Stamp::erase_invalid_code($i_com);

# �G���[�ƃv���r���[
if($in{'preview'} || $main::e_com){ &memo_view("ERROR",$thread_number); }

# ���b�N�J�n
&lock($moto);

# �����{�����`
$renew_thread{'memo_body'} = $i_com;

# �����̕ҏW���e���`
my($put_handle,$put_id,$put_xip) = ($i_handle,$encid,$main::xip);
$put_handle =~ s/=//g; $put_id =~ s/=/-/g; $put_xip =~ s/=//;
$renew_thread{'memo_editor'} = "$put_handle=$put_id=$enctrip=$main::time=$put_xip=$host=$main::cnumber=$main::myaccount{'file'}=$date";

# �L�����X�V
my($thread) = Mebius::BBS::thread({ ReturnRef => 1 , Renew => 1 , TypeFileCheckError => 1 , select_renew => \%renew_thread },$main::moto,$thread_number);

# �L�����Ƃ̍������X�V
my $history_renew_line = qq($main::host<>$main::agent<>$main::cnumber<>$main::myaccount{'file'}<>\n);
#qq($key2<>$memo_body<>$i_com<>$main::time<>$main::i_handle<>$main::encid<>$main::i_trip<>$main::host<>$main::agent<>$main::cnumber<>$main::myaccount{'file'}<>\n);
&bbs_memo_history("Renew New-line",$main::moto,$main::file,"$th{'memo_body'}<>$i_com<>$main::i_handle<>$main::encid<>$enctrip");

	# �f���C���f�b�N�X���X�V
	if($th{'key'} eq "1" || $th{'key'} eq "2" || $th{'key'} eq "5"){
		my(%index_line_control);
		require "${main::int_dir}part_res.pl";
		$index_line_control{$thread_number}{'last_handle'} = "�����X�V";
		Mebius::BBS::index_file({ Renew => 1 , RegistMemo => 1 , line_control => \%index_line_control },$main::moto);
		#&memo_indexsort("",$thread_number);
	}

	# XIP�f�[�^����������
	if(!$main::admin_mode){
		Mebius::Fileout(undef,"${share_directory}_ip/_ip_memo/${main::xip_enc}.cgi","$main::time");
	}

	# ���̊m���ŌÂ��w�h�o�t�@�C����S�폜
	if(rand(1000) < 1){
		&oldremove("","${share_directory}_ip/_ip_memo","30");
	}

# ���b�N����
&unlock($moto);

	# �V�����X�g���X�V
	if(!$main::secret_mode){
		my(%renew_list);
		my($init_directory) = Mebius::BaseInitDirectory();
		require "${init_directory}part_newlist.pl";
	main::EditMemoList({ TypeRenew => 1 , TypeNewLine => 1 , NewSubject => $th{'subject'} , NewTitle => $main::title , NewMoto => $moto , NewThreadNumber => $in{'no'} , NewBeforeText => $th{'memo_body'} , NewAfterText => $i_com , NewHandle => $main::i_handle , NewTrip => $main::i_trip });
	}

	# �Ǘ����[�h�̃��_�C���N�g
	if($main::admin_mode){

		Mebius::Redirect(undef,$thread->{'admin_url'});

	# �N�b�L�[���Z�b�g
	} else {

		Mebius::Cookie::set_main({ last_memo_time => time , name => $main::in{'name'} },{ SaveToFile => 1 });
		# ���e�����t�@�C�����X�V
		Mebius::HistoryAll("Renew My-file");

		# HTML
		Mebius::Redirect(undef,$thread->{'url'});


	}


exit;

}



#-----------------------------------------------------------
# ��{�G���[�`�F�b�N - strict
#-----------------------------------------------------------
sub memo_base_error_check{

# �錾
my($brnum,$big_length);
our($int_dir,$postflag,$getflag,$i_com,$i_res,$e_com,$e_access);
our(%in,$moto,$ngbr,$memo_maxmsg,$guide_url);

# �R�����g
our($i_com) = ($in{'comment'});

	# �e��G���[
	if(!$postflag && !$getflag) { $e_access .= "���s���ȃA�N�Z�X�ł��B<br>"; }

# ��荞�ݏ���
require "${int_dir}regist_allcheck.pl";

# ��{�ϊ�
($i_com) = &base_change($i_com);

# �e��G���[
my($big_length) = &get_length("",$i_com);
	if($big_length > $memo_maxmsg) { $e_com .= "���{���̕��������������܂��B�i ����$big_length���� / �ő�$memo_maxmsg���� �j<br>";  }
($brnum) = ($i_com =~ s/<br>/<br>/g);
	if($brnum > $ngbr) { $e_com .= "�����s���������܂��B���s���������炵�Ă��������B�i ����$brnum�� / �ő�$ngbr�� �j<br>"; }
	if(($i_com eq "")||($i_com =~ /^(\x81\x40|\s|<br>)+$/)) { $e_com .= qq(���{��������܂���B���������Ă��������B<br>); }

	# �A�����s�̔���Ɛ���
	if($i_com =~ /((<br>){10,})/){
	$e_com .= qq(��<a href="${guide_url}%B2%FE%B9%D4">�A�����s�̂������ł��B���s�̘A�������炵�Ă��������B</a><br>
	�@�L�������Â炭�Ȃ邽�߁A���s�͂P�`�R���͈̔͂ł����Ȃ��Ă��������B<br>); 
	}

# �e��`�F�b�N
main::all_check(undef,$i_com,$in{'name'});

}



#-----------------------------------------------------------
# �����̍폜�i�V�j
#-----------------------------------------------------------
sub memo_delete_history{

# �錾
my($type) = @_;

	&bbs_memo_history("Delete-line Renew",$main::moto,$main::in{'no'});

Mebius::Redirect("","${main::jak_url}$main::moto.cgi?mode=memo&no=$main::in{'no'}");


}



#-----------------------------------------------------------
# �L�������̃`���[�W���� - strict
#-----------------------------------------------------------
sub get_memo_chargetime{

# �錾
my($top,$chargetime,$chargemin,$chargesec,$lasttime);
our($time,$xip_enc,$admin_mode,$cmemo_time,$memo_wait);
my($share_directory) = Mebius::share_directory_path();

# XIP�f�[�^�J��
open(XIP_IN,"<","${share_directory}_ip/_ip_memo/${xip_enc}.cgi");
$top = <XIP_IN>; chomp $top;
close(XIP_IN);

# �҂����Ԕ���
$lasttime = $top;
$chargetime = $lasttime + $memo_wait*60 - $time;
if($chargetime <= 0){ $chargetime = $cmemo_time + $memo_wait*60 - $time; }

$chargemin = int($chargetime / 60);
if($chargemin){ $chargesec = $chargetime % ($chargemin*60); }
else{ $chargesec = $chargetime; }

# �Ǘ��ҁA���[�J���ő҂����Ԃ��Ȃ���
if($main::bbs{'concept'} =~ /Local-mode/ || $admin_mode){ $chargetime = undef; }

return($chargetime,$chargemin,$chargesec);

}


1;
