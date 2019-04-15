
use strict;
use Mebius::BBS;
use Mebius::Handle;
use Mebius::Paint;

#-----------------------------------------------------------
# ���e��̉�� - strict
#-----------------------------------------------------------
sub regist_posted{

# �錾
my($type,$i_postnumber,$i_resnumber,$i_sub,$i_com) = @_;
my($my_cookie) = Mebius::my_cookie_main_logined();
my($init_bbs) = Mebius::BBS::init_bbs_parmanent_auto();
my($my_use_device) = Mebius::my_use_device();
my($posted_line,$getgold_line,$nextcharge_line,$newposted_line,$results_line,$kiriban_line,$join_line,$message_line,$cermail_line,$error_cermail,$cermail_message,$tell_deleted_line,$print,$setted_cookie);
our(%in,$realmoto,$moto,$int_dir,$i_res,$new,$sub_title,$head_link3,$head_link4);
our($nextcharge_time,$jump_sec,$jump_url,$server_domain,$moto,$css_text,$i_nam);
our($i_handle,$smlength,$csilver,$kflag,$alocal_mode,$pmfile,$mebicheck_line,$head_title);
our($m_max,$agent,$smlength,$minus_length);
our($door_url,$home,$norank_wait);
our($cookie,$head_javascript);
our($xclose,$agent,$kborder_bottom_in);
my $bbs_path = Mebius::BBS::Path->new($realmoto,$i_postnumber,$i_resnumber);
my $time = time;
my $thread_url = $bbs_path->thread_url_adjusted();

# �L���̃g�b�v�f�[�^���擾
my($thread) = Mebius::BBS::thread_state($i_postnumber,$realmoto);

# �����`�F�b�N
$i_postnumber =~ s/\D//g;
$i_resnumber =~ s/\D//g;

# �^�C�g����`
$sub_title = "���e��� | $head_title";
$head_link3 = qq( &gt; <a href="$thread_url">$i_sub</a>);
$head_link4 = " &gt; ���e����";

# ���r�����`�F�b�N���擾
#my($mebicheck_line) = get_mebicheck("",$moto,$i_postnumber,$i_resnumber,$i_sub);
my($mebicheck_line);

# ���݂̑������v�Z
require "${int_dir}part_waitcheck.pl";
my($getgold) = getgold_from_comment("",$in{'comment'},$thread->{'concept'});

	# ���m�点���[�����h�o�^�h
	if($main::in{'email'} && $main::in{'email_tell'} eq "tell"){
		require "${main::int_dir}part_cermail.pl";
		($error_cermail,$cermail_message) = Mebius::Email::SendCermail("BBS-thread Post-regist",$main::in{'email'},$main::moto,$i_postnumber);
		#$main::cemail = $main::in{'email'};
	}

	# �Ǘ��ҍ폜�̂��m�点
	my(%penalty) = Mebius::penalty_file("Select-auto-file Get-hash-only");
	if($penalty{'tell_flag'}){
		$tell_deleted_line .= qq(<div class="tell_deleted" style="background:#fee;$main::kborder_bottom_in">\n);
		$tell_deleted_line .= qq(<span style="color:#f00;">���m�点�F</span>\n);
		$tell_deleted_line .= qq(�@ $penalty{'deleted_link'} �ŊǗ��ҍ폜������܂����B\n);
			if($penalty{'deleted_reason'}){ $tell_deleted_line .= qq(<br$main::xclose><span style="color:#f00;">�폜���R�F</span>�@ $penalty{'deleted_reason'} \n); }
			if($penalty{'deleted_comment'}){
					if($main::kflag){ $penalty{'deleted_comment'} =~ s/<br>/<br$main::xclose>/g; }
				$tell_deleted_line .= qq(<br$main::xclose><span style="color:#f00;">�{���F</span>);
				$tell_deleted_line .= qq(<div class="tell_deleted_comment line-height">$penalty{'deleted_comment'}</div>\n);
			}
		$tell_deleted_line .= qq(</div>\n);
	}


	# �����C���� Cookie ���Z�b�g����
	{
		# �Z�b�g����N�b�L�[�̒�`
		my(%set_cookie);

			# ����ʃ��[�U�[����
			if(!Mebius::Admin::admin_mode_judge()){
				my($id_history_level) = Mebius::BBS::id_history_level_judge({ from_encoding => "sjis" });
					if($id_history_level->{'set_cookie_value'}){ $set_cookie{'use_id_history'}  = $id_history_level->{'set_cookie_value'}; }
				$set_cookie{'name'} = $i_nam;
				$set_cookie{'+'}{'regist_all_length'} = $smlength;
				$set_cookie{'+'}{'regist_count'} = 1;
				$set_cookie{'last_res_time'} = $time;
				$set_cookie{'wait_second_res'} =  $nextcharge_time;
				$set_cookie{'+'}{'gold'} = $getgold;
			}
			
			# �� �Ǘ����[�U�[ / ��ʃ��[�U�[����
			{
					if($main::in{'email'} ne 'example@ne.jp'){ $set_cookie{'email'} = $main::in{'email'}; }
					if($in{'thread_up'} eq "") { $set_cookie{'thread_up'} = 2; } else { $set_cookie{'thread_up'} = 1; }
					#if($in{'news'} eq "" || $in{'news'} eq "2") { $set_cookie{'bbs_news'} = 2; } else { $set_cookie{'bbs_news'} = 1; }
					if($pmfile){
							if($in{'account_link'} eq "" || $in{'account_link'} eq "2") { $set_cookie{'account_link'} = 2; } else { $set_cookie{'account_link'} = 1; }
							if($in{'account_link'} eq "") { $set_cookie{'account_link'} = 2; } else { $set_cookie{'account_link'} = 1; }
					}
				$set_cookie{'font_color'} = $in{'color'};

			}

		($setted_cookie) = Mebius::Cookie::set_main(\%set_cookie,{ SaveToFile => 1 });

	}

	# �����[�U�[��������	
	if(!Mebius::Admin::admin_mode_judge()){

		# �f���p��Cookie���Z�b�g
		Mebius::Cookie::set("bbs",{ last_regist_bbs_kind => $realmoto , last_regist_thread_number => $i_postnumber , last_regist_res_number => $i_resnumber , last_regist_words_length => $smlength , last_get_gold_num => $getgold , last_regist_time => time });

			# ���݃����L���O���X�V
			if($my_cookie->{'call_save_data_flag'}){
				require "${main::int_dir}part_newlist.pl";
				Mebius::Newlist::goldranking("RENEW GOLD","","","$setted_cookie->{'gold'}<>$main::pmfile<>$main::i_handle<>$main::encid<>$main::kaccess_one<>$main::k_access");
			}

		# ���G�����摜���m�肳����
		Mebius::Paint::Image("Rename-justy Renew-logfile-justy",$in{'image_session'},undef,$server_domain,$realmoto,$i_postnumber,$i_resnumber);
		Mebius::Paint::Image("Posted Renew-logfile-buffer",$in{'image_session'});

		# �M�������L���O�t�@�C�����X�V
		Mebius::BBS::Handle("New-count Renew",$main::i_handle,$main::enctrip,$main::thisyear,$main::thismonthf,$main::moto,$main::realmoto,$i_postnumber,$i_resnumber,$i_sub);

	}

	# ���O�h���C���łȂ���΋L�^
	if($main::host !~ /(\.jp|\.net)$/){
		Mebius::AccessLog(undef,"Foreign-posted");
	}

	# ����ł̓A�N�Z�X���O���L�^
	if($main::realmoto eq "qst"){
		Mebius::AccessLog(undef,"Qst-boad-posted");
	}

	# ���_�C���N�g
	if(!$my_use_device->{'mobile_flag'}){
		Mebius::redirect("$thread_url#S$i_resnumber");

		# ���X���e�ł��m�点���[���𑗐M
			if($in{'res'}){ thread_sendmail_res("",$moto,$i_postnumber,$i_resnumber,$i_sub,$i_handle,$i_com); }

		exit;
	}


# ����܂ł̐��т��擾
($results_line) = &get_results();

# �L���ԃQ�b�g
($kiriban_line) = &posted_get_kiriban("",$i_resnumber,$m_max);

# �J�E���g�_�E�����擾
require "${int_dir}part_timer.pl";
my($head_javascript) = &get_timer("",$nextcharge_time,"posted");

# �����������������݂܂���
$posted_line = qq(<strong class="bignum">$smlength����</strong> ���������݂܂����B);

# ����`���[�W���Ԃ̕\��
my($nextcharge_minute,$nextcharge_sec) = &minsec("",$nextcharge_time);
$nextcharge_line .= qq(
<form name="posted" class="nextcharge_line">
<div style="display:inline;vertical-align:bottom;">
����`���[�W��
<script type="text/javascript">
<!--
document.write('<input type="text" name="waitsecond" value="" class="wait_input" readonly>');
//-->
</script>
<noscript><p class="noscript">
<span class="nextcharge">����`���[�W�� $nextcharge_minute��$nextcharge_sec�b �ł��B</span>
</p></noscript>
�ł��B);

	if($norank_wait){ $nextcharge_line .= qq(�i�ꗥ�j); }
	#else{ $nextcharge_line .= qq(�i<a href="/_waitlist/">?</a>�j); }
$nextcharge_line .= qq(</div></form>�@);

	if($kflag || $agent =~ /Nintendo Wii/){
$nextcharge_line = qq(����`���[�W�� $nextcharge_minute��$nextcharge_sec�b �ł��B�@);
	}

	# ���݂̑���
	if($cookie){
		if($getgold > 0){ $getgold_line .= qq(�������񏑂����̂ŁA���݂� <strong class="plus_gold">$getgold��</strong> �����܂����B); }
		elsif($getgold < 0){
			my $gold = $getgold;
			$gold =~ s/^\-//g;
			$getgold_line .= qq(���܂菑���Ȃ������̂ŁA���݂� <strong class="minus_gold">$gold��</strong> ����܂����B);
		} else{ $getgold_line .= qq(���݂̑����͂���܂���B); }
		if($setted_cookie->{'gold'} >= 0){ $getgold_line .= qq( <a href="${main::main_url}rankgold-p-1.html"><img src="/pct/icon/gold2.gif" alt="����" title="����" class="noborder"></a> $setted_cookie->{'gold'}); }
		else{ $getgold_line .= qq( <a href="${main::main_url}rankgold-p-1.html"><img src="/pct/icon/gold2.gif" alt="����" title="����" class="noborder"></a> <span class="blue">$setted_cookie->{'gold'} (�؋�)</span>); }
	}
	if($getgold_line){ $getgold_line = qq(<span class="getgold_line">$getgold_line</span>�@); }

# �L���o���Ȃ�
if($kiriban_line){ $posted_line = $kiriban_line; }

	# �v���[���g�Ȃǃ��b�Z�[�W
	#if($cmessage){
	#	if($kflag){ $message_line = qq(<hr$main::xclose>$cmessage <a href="${main::mainscript}?mode=my&amp;k=1&amp;message_check=1#MESSAGE">?</a>); }
	#	else{ $message_line = qq(<div class="message">$cmessage <a href="${main::mainscript}?mode=my&amp;message_check=1#MESSAGE">?</a></div>); }
	#}

	# �V�K���e�̏ꍇ
	if($in{'res'} eq ""){
		$newposted_line = qq(<strong class="bignum">$head_title</strong>�ɂ܂��ЂƂA�V���ȋL�������܂�܂����B);
		($nextcharge_line,$getgold_line) = undef;
	}

	# ���m�点���[�����b�Z�[�W
	if($error_cermail){
		$cermail_line .= qq(���̗��R�ŁA���m�点���[���o�^�͏o���܂���ł����B$error_cermail);
	}
	if($cermail_message){
		$cermail_line .= qq($cermail_message);
	}
	if($cermail_line){
		$cermail_line = qq(<div class="cermail page-width line-height">$cermail_line</div>);
	}

# �g�ѐݒ���Ď擾
if($kflag){ &kget_items(); }

	# �C���f�b�N�X����肱��ŕ\�� ( �g�є� )
	if($kflag){
		$join_line .=  qq(<div style="font-size:small;">);
		$join_line .=  qq(<div style="background:#eee;$main::kborder_bottom_in">$posted_line $newposted_line);
		$join_line .=  qq($nextcharge_line);
		$join_line .= qq((<a href="$i_postnumber.html#S$i_resnumber">�����L��</a> / <a href="./">���f����</a>) </div>);
		$join_line .= qq($tell_deleted_line);
		$join_line .=  qq($message_line);
		#$join_line .=  qq($line_invite);
		$join_line .=  qq($cermail_line);
		$join_line .=  qq($results_line);
		$join_line .=  qq(</div>);

		$print .= $join_line;

		#require "${int_dir}k_indexview.pl";
		#&view_kindexview("JOIN",$join_line);
	}


	# HTML ( �f�X�N�g�b�v�� )
	else{

		#my($sorcial_line) .= Mebius::Gaget::tweet_button({ url => $thread->{'url'} , title => $thread->{'sub'} });
		my $gaget = new Mebius::Gaget;
		my $sorcial_line = qq( �� ). $gaget->tweet_button({ url => $thread->{'url'} , text => "$thread->{'sub'} | $init_bbs->{'head_title'}" });

		$print .= qq(
		<div class="posted page-width">
		<div class="posted_linetop">$posted_line</div>
		<div class="posted_line">$newposted_line $getgold_line $nextcharge_line $message_line $tell_deleted_line</div>
		<div class="back_links">
		<a href="$door_url">��</a> &gt; 
		<a href="$home">�s�n�o�y�[�W</a> &gt;
		<a href="/_$moto/">�f���ɖ߂�</a> &gt; 
		<a href="/_$realmoto/$i_postnumber.html">�L���ɖ߂�</a> <a href="/_$realmoto/$i_postnumber.html#S$i_resnumber">( �� )</a>
		$sorcial_line
		</div>
		</div>
		$cermail_line
		<div class="left_right page-width">
		$results_line
		$mebicheck_line
		<div class="clear"></div>
		</div>
		);
	}

Mebius::Template::gzip_and_print_all({ head_javascript => $head_javascript },$print);

	if($my_use_device->{'mobile_flag'}){
			if($in{'res'}){ thread_sendmail_res("",$moto,$i_postnumber,$i_resnumber,$i_sub,$i_handle,$i_com); }
	}

exit;

}


#-----------------------------------------------------------
# ����܂ł̐��т��擾 - strict
#-----------------------------------------------------------
sub get_results{

# �錾
my($line,$heikin,$hyouka,$point,$viewgold,$text_comesns,$backurl_gold_query_enc);
our($cookie,$cgold,$csoutoukou,$csoumoji,$idcheck,$guide_url,$server_domain,$css_text);
our($kflag,$xclose,$moto,$server_domain);

# CSS��`
$css_text .= qq(
div.results_body{float:left;width:45%;background-color:#def;border:solid 1px #67f;line-height:1.2em;padding:1.3em 2%;margin:1em 0em 0.5em 0em;}
.seiseki{color:#24f;font-size:110%;}
table,th,tr,td{color:#333;border-style:none;color:#22d;}
table{margin-top:1em;}
td{padding:0.2em 2.0em 0.2em 0.0em;font-size:100%;}
div.results{line-height:1.6em;}
.hyouka{color:#f00;font-size:130%;}
.seiseki_plusgold{font-size:150%;}
.seiseki_minusgold{font-size:140%;color:#00f;}
);

# ���݃����N�̖߂��URL���` (�g�є�)
$backurl_gold_query_enc = Mebius::Encode("","http://$server_domain/_$moto/");

	# ���ѕ\�� ( �g�є� )
	if($kflag && $cgold ne "" && $cookie){
		my($average);
			if($csoutoukou && $csoumoji){ $average = int($csoumoji / $csoutoukou); }
			# <a href="$main::gold_url?k=1&amp;backurl=$backurl_gold_query_enc"$main::sikibetu><img src="/pct/icon/gold2.gif" alt="����"$xclose></a>
		$line .= qq(
		<span style="color:#f00;">������ $cgold�� <img src="/pct/icon/gold2.gif" alt="����"$xclose> / ���e $csoutoukou�� / ���� $average����</span> 
		( <a href="http://$server_domain/">$server_domain</a> ) <br$main::xclose>
		);
			$line .= qq(<a href="${main::main_url}rankgold-k-1.html">�����݃����L���O</a>);
			if($main::bbs{'concept'} !~ /Not-handle-ranking/){ $line .= qq( / <a href="./ranking.html">���Q�������L���O</a>); }
		return($line);
	}

#<a href="${guide_url}%B6%E2%B2%DF">?</a>

# Cookie�������ꍇ�A���^�[��
if(!$csoumoji || !$csoutoukou || !$cookie){
$line = qq(
<div class="results_body">
���̊��ł́A���т̋L�^�͂���܂���B
</div>
);
return($line);
}

$heikin = int($csoumoji / $csoutoukou);
$point  = int($heikin + ($cgold*0.5));

# �]�����e���`

if($csoutoukou >= 250){
if($point >= 2000){$hyouka='���Ȃ��������Ȃ郁�r���[�ł��I';}
elsif($point >= 1500){$hyouka='�S�m�S�\�ɂȂꂻ���ł��I';}
elsif($point >= 1000){$hyouka='�S�Ă���ɓ��肻���ł��I';}
elsif($point >= 900){$hyouka='���G�͑����o�����܂����I';}
elsif($point >= 800){$hyouka='�E�]�ƍ��]���Ȃ��肻���ł��I';}
elsif($point >= 700){$hyouka='����@�ւ��X�p�[�N�������ł�';}
elsif($point >= 600){$hyouka='�~�߂���͉̂�������܂���I';}
}

if(!$hyouka && $csoutoukou >= 100){
if($point >= 500){$hyouka='�g�ɏ���Ă��܂��I';}
elsif($point >= 450){$hyouka='�X�[�p�[�O���[�g�b�I';}
elsif($point >= 400){$hyouka='�O�A�O���[�g�b�I';}
elsif($point >= 350){$hyouka='�O���[�g�I';}
elsif($point >= 300){$hyouka='�X�[�p�[�G�N�Z�����g�I';}
elsif($point >= 250){$hyouka='�G�N�Z�����g�I';}
elsif($point >= 200){$hyouka='�ō��ɗǂ��o���܂���';}
elsif($point >= 175){$hyouka='�f���炵���ǂ��o���܂���';}
elsif($point >= 150){$hyouka='�����ւ�ǂ��o���܂���';}
elsif($point >= 125){$hyouka='�ƂĂ��ǂ��o���܂���';}
}

if(!$hyouka){
if($point >= 100){$hyouka='�ǂ��o���܂���';}
elsif($point >= 75){$hyouka='���ƈꑧ�ł�';}
elsif($point >= 50){$hyouka='���ʂł�';}
elsif($point >= 40){$hyouka='�܂�����Ȃ���ł�';}
elsif($point >= 30){$hyouka='�撣��܂��傤';}
elsif($point >= 20){$hyouka='�^�ʖڂɂ��܂��傤';}
elsif($point >= 10){$hyouka='���܂�ǂ�����܂���';}
elsif($point >= 5){$hyouka='����܂�ł�';}
else{$hyouka='�]���ΏۊO'}
}

# ���ݖ����̕\�����`
my($txt_gold) = ($cgold);
if($cgold == 0){ $txt_gold = "0"; }
if($cgold >= 0){ $viewgold = qq(<strong class="seiseki_plusgold">$txt_gold��</strong>); }
else{ $viewgold = qq(<strong class="seiseki_minusgold">$txt_gold�� (�؋�)</strong>); }

# �K�C�h�e�L�X�g
if(!$idcheck){ $text_comesns = qq(<tr><td colspan="3"><span class="comesns">��<a href="http://mb2.jp/_auth/">���r�����r�m�r</a>�ɓo�^/���O�C������ƁA���݂₱��܂ł̐��т������ɂ����Ȃ�܂��B</span></td></tr>);  }

$line .= qq(
<div class="results_body">
<strong class="seiseki">������܂ł̐���</strong>�@( <a href="http://$server_domain/">$server_domain</a> )
<table class="results" summary="����܂ł̐���">
<tr><td>���e</td><td>$csoutoukou��</td><td>);

if($main::bbs{'concept'} !~ /Not-handle-ranking/){ $line .= qq(<a href="./ranking.html">�������L���O</a>); }

$line .= qq(</td></tr>
<tr><td>���v</td><td>$csoumoji����</td><td></td></tr>
<tr><td>����</td><td>$heikin����</td><td><a href="/_main/allpost-p-1.html">���T�C�g�S��</a></td></tr>
<tr><td>�]��</td><td>$hyouka</td><td></td></tr>
$text_comesns
</table>
</div>
);

return($line);

}


#-----------------------------------------------------------
# ���r�����`�F�b�N�̎擾 - strict
#-----------------------------------------------------------
sub get_mebicheck{

# �錾
my($type,$moto,$i_postnumber,$i_resnumber,$i_sub) = @_;
my($rand_check,$check_print,$after_check_text,$check_title,$kr_view);
my($checked1,$checked2,$check_folder);
our($script,$sikibetu,$int_dir,$sikibetu,$time);
our(%in,$server_domain,$kflag,$checked,$xclose);
our($thisyear,$thismonth,$today,$guide_url,$title,$cemail,$concept);

# �����`�F�b�N
$moto =~ s/\W//g;
$i_postnumber =~ s/\D//g;
$i_resnumber =~ s/\D//g;

# ���e��e�L�X�g�̊m���ݒ�
my $rand_m_check = 67;
my $rand_a_check = 24;
my $rand_h_check = 66;

# �����̐�Γ��t�l���Z�o(���{����)
my $today_time = int( ($time + 9*60*60) / (24*60*60) );

	# ���r�����X�^�[
	if(rand(100) < 1){ require "${int_dir}part_star.pl"; ($check_print,$check_title) = &posted_get_star(); }

	# �~�b�V�����E�`�F�b�N
	elsif(rand(3) < 1){

	# ��Γ��t�Ń`�F�b�N������
	$rand_check = $today_time % $rand_m_check;
	if(!$rand_check){ $rand_check = $rand_m_check; }

	$check_title="���~�b�V�����ł��I - $thisyear�N$thismonth��$today��";
	$check_folder="_check_m";

	($check_print) .= &check_open($check_folder,$rand_check);

	$check_print .= qq(<br>���񍐂�<a href="http://aurasoul.mb2.jp/_qst/2741.html">�񍐋L��</a>�A�V��Ă�<a href="http://aurasoul.mb2.jp/_qst/1989.html">���r�����</a>�܂ŁB<br>);

	}

	# �֘A�L��
	elsif(rand(2) < 1 && $concept !~ /NOT-KR/ && -e "${int_dir}_kr/$moto/${i_postnumber}_kr.cgi"){

		# �Ǐ���
		my($maxview);

			# �֘A�L���̍ő�\����
			if($kflag){ $maxview = 3; } else{ $maxview = 5; }

		# �֘A�L�����擾
		require "${int_dir}part_kr.pl";
		my($kr_line) = related_thread("Index",$moto,$i_postnumber,$maxview); 

		$check_title="����������ǂ��� ( �֘A�����N )";
		$check_print = qq($kr_line);

	}

	# �܂���̈ꌾ
	else{

		# ��Γ��t�Ń`�F�b�N������
		$rand_check = $today_time % $rand_h_check;
		if(!$rand_check){ $rand_check = $rand_h_check; }

		$check_title="���܂���̈ꌾ - $thisyear�N$thismonth��$today��";
		$check_print .= qq(<div class="dmaricon"><a href="${guide_url}%A4%DE%A4%EA%A4%E2"><img src="/pct/maricon.GIF" alt="�܂���A�C�R��" class="maricon"></a></div>);
		$check_folder="_check_h";
		($check_print) .= &check_open($check_folder,$rand_check);
	}


# ���������N
$check_print = &bbs_regist_auto_link($check_print);

$check_print = qq(
<div class="mebi_check">
<strong class="check">$check_title</strong><br$xclose><br$xclose>
$check_print
$after_check_text
</div>
);

	# �g�єłł̐��`
	if($kflag){
		$check_print =~ s/<br>/<br$xclose>/g;
		$check_print =~ s/<img (.+?)>/<img $1$xclose>/g;
		$check_print =~ s/<input (.+?)>/<input $1$xclose>/g;
		$check_print =~ s/<br$xclose><br$xclose>/<br$xclose>/g;
		$check_print =~ s/<br$xclose>\n<br$xclose>/<br$xclose>/g;
	}

return($check_print);


}

#-----------------------------------------------------------
# ���r�����`�F�b�N�̃f�[�^�J��(�T�u���[�`���j
#-----------------------------------------------------------
sub check_open{

# �錾
my($check_folder,$rand_check) = @_;
my($line);
our($int_dir);

$rand_check =~ s/\D//g;
open(MEBICHECK_IN,"<","${int_dir}$check_folder/$rand_check\.cgi");
while(<MEBICHECK_IN>){ $line .= "$_<br>"; }
close(MEBICHECK_IN);

return($line);

}

#-------------------------------------------------
# �L���o�����e�A���߂łƂ��̕��͂��` - stricg
#------------------------------------------------
sub posted_get_kiriban{

# �錾
my($type,$res,$m_max) = @_;
my($txt_ban,$omedetou_text);
our($m_max,$kflag);

# ���^�[��
if($res <= 0){ return; }

my $res_amari100 = $res % 100;
my $res_amari1000 = $res % 1000;

if($kflag){ $txt_ban = qq($res�Ԗ�); }
else{ $txt_ban = qq(<strong class="ome">$res�Ԗ�</strong>); }

if($res =~ /111$/ || $res =~ /222$/ || $res =~ /333$/ || $res =~ /444$/ || $res =~ /555$/ || $res =~ /666$/ || $res =~ /777$/ || $res =~ /888$/ || $res =~ /999$/)
{ $omedetou_text = "$txt_ban�i�]���j�̓��e�ł��B�����͋g���I"; }

if($res_amari100 == 0 && $res){ $omedetou_text = "$txt_ban�̓��e�ł��B���߂łƂ��I"; }
if($res_amari1000 == 0 && $res){ $omedetou_text = "�Ȃ��$txt_ban�̓��e�ł��B�O���[�g�I"; }
if($res == $m_max && $m_max){ $omedetou_text = "����[�I�@�ȁA�Ȃ��$txt_ban�A<br>���̋L���ōŌ�̏������݂ł��B�{���ɂ��߂łƂ��I<br>"; }

return($omedetou_text);

}

1;
