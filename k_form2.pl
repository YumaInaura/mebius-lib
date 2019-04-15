
package main;
use Mebius::BBS::Form;

#-----------------------------------------------------------
# �g�є� ���e�t�H�[��
#-----------------------------------------------------------
sub bbs_thread_form_mobile{

# �錾
my($job) = @_;
my($submit,$tcount,$next_resnumber,$print);
my($my_account) = Mebius::my_account();
our($time,%in,$last_res,$concept,$stop_regist_mode);

my(%emoji) = Mebius::Emoji;
my($emoji_shift_jis) = Mebius::Encoding::hash_to_shift_jis(\%emoji);



# ���M�p�A���݂̃��X��
	if($in{'resnum'}){ $next_resnumber = $in{'resnum'}; }
	else{ $next_resnumber = $res + 1; }

$kflag = 1;

# �g�єŁ@�V�K���e�̏ꍇ
if ($job eq "new") { $print .= "�V�K���e"; }

# �폜/���b�N/�x�����R���擾
my($alert_person,$alert_date,$alert_lasttime,$alert_reason) = split(/=/,$d_delman);
my($alert_reason_text);
	if($alert_reason){
		require "${int_dir}part_delreason.pl";
		($alert_reason_text) = &delreason($alert_reason,undef,$sub,$head_title);
			if($alert_reason_text){ $alert_reason_text = qq(<span style="color:#f00;">$alert_reason_text</span>); }
	}

# ���b�N����p�̗\������
require "${main::int_dir}part_thread_status.pl";
my($alert_line) = &thread_status_lock("LOCK DESKTOP Mobile-view",$d_delman,$lock_end_time);


	# ���e�t�H�[����\�����Ȃ��ꍇ
	if($newwait_flag) { $print .= "<hr$xclose>�V�K���e�́A���� $zan_day��$zan_hour����$zan_minute�� �҂��Ă��������B\n"; $return = 1; } 
	elsif ($key eq '0' && $alert_line) {
		$print .= qq(<hr$xclose$alert_line\n);
		$return = 1;
	}
	elsif ($key eq '3') { $print .= "<hr$xclose>���̋L���͉ߋ����O�ł��B\n"; $return = 1; }
	elsif ($key eq '7') { $print .= "<hr$xclose>���̋L���͍폜�\\�񒆂ł��B�����Ԍ�ɁA�����I�ɍ폜����܂��B$alert_reason_text\n"; $return = 1; }
	elsif($concept =~ /Not-regist/){  $print .= qq(<hr$xclose>���̌f���͏������ݒ�~���ł��B\n); $return = 1; }
	elsif($stop_regist_mode){  $print .= qq(<hr$xclose>���݁A���e���󂯕t���Ă��܂���B\n); $return = 1; }
	elsif (($m_max *0.9) < $res) {
		$print .= qq(<hr$xclose>���X$res��/�ő�$m_max��\n);
			if($m_max <= $res){ $return = 1; }
	}
	elsif ($krule_on) { $return = 1; }


	# �I��
	if($return){ return($print); }

	# �x��
	if ($thread_key =~ /Alert-violation/){
			if($alert_lasttime + 30*24*60*60 >= $main::time){
				$print .= qq(<div style="background:#fbb;$ktextalign_center_in$kborder_top_in">�Ǘ��҂��(�d�v)</div>);
				$print .= qq($emoji_shift_jis->{'alert'}$alert_reason_text);
				$print .= qq(<br$main::xclose>$emoji_shift_jis->{'alert'}���̏�Ԃ������ꍇ�A�L�������b�N/�폜�����Ă��������ꍇ������܂��B);
			}

	}

# �摜�Y�t
if($main::bbs{'concept'} =~ /Upload-mode/){ require "${int_dir}part_upload.pl"; &upload_setup("k"); }

if($rule_text && $job eq "new"){
# ���[�������o��
print"<hr$xclose>��$title�̃��[��<br$xclose>";
if($concept !~ /DOUBLE-OK/ && $main::bbs{'concept'} !~ /Sousaku-mode/){
print"��<a href=\"${guide_url}%BF%B7%B5%AC%C5%EA%B9%C6\">�V�K���e</a>�̑O��
<a href=\"${guide_url}%BD%C5%CA%A3%B5%AD%BB%F6\">�d���L��</a>���Ȃ���<a href=\"kfind.html\">����</a>���Ă��������B<br$xclose>";}
$rule_text =~ s/<br>/<br$xclose>/g;
$rule_text =~ s/<br><br>/<br>/g;
$print .= "$rule_text<br$xclose>";
}


	# �X�g�b�v���[�h
	if(Mebius::Switch::stop_bbs()){
		$print .= qq(<div style="color:#f00;border-top:solid 1px #000;">���݁A�f���S�̂œ��e��~���ł��B</div>);
		return $print;
	}



# ���e�t�H�[��
$print .= qq(<form action="$script" method="post"$formtype$sikibetu><div>);


	# �ԐM�t�H�[���̑�
	if($job eq "new"){ $print .= qq(<div style="background:#9f9;text-align:center;$kborder_top_in">�V�K���e�t�H�[��</div>); }
	else{
		$print .= qq(<div style="background:#9f9;text-align:center;$kborder_top_in">);
		$print .= qq( $emoji_shift_jis->{'number5'}<a href="#ARESFORM" id="ARESFORM" accesskey="5">�ԐM</a></div>);
	}


# ���e�O�̒���

$print .= qq(<div>);

	# ���[���\��
	if($job ne "new"){
	if($subtopic_mode){ $print .= qq($emoji_shift_jis->{'exclamation'}�{�҂�<a href="/_$moto/$in{'no'}.html">���C���L��</a>�ւǂ���<br$xclose>); }
	elsif($subtopic_link && $subkey ne "0"){ $print .= qq($emoji_shift_jis->{'exclamation'}���z/���Ă�<a href="/_sub$moto/$in{'no'}.html"$sub_nofollow>��ދL��</a>�ւǂ���<br$xclose>); }
	}

	if($rule_text && $job eq ""){
	$print .= qq($emoji_shift_jis->{'exclamation'}<a href="${guide_url}%C0%DC%C2%B3%A5%C7%A1%BC%A5%BF">�ڑ��f�[�^���ۑ�����܂�</a><br$xclose>);
	$print .= qq($emoji_shift_jis->{'exclamation'}<a href="${guide_url}%A5%E1%A5%D3%A5%A6%A5%B9%A5%EA%A5%F3%A5%B0%B6%D8%C2%A7">�S��ٰ�</a>��<a href="krule.html">��ٰ�</a>��);
	$print .= qq(<span style="color:#f00;">�K��</span>�ł�<br$xclose>
	);
	}



$print .= qq(</div><hr$main::xclose>);


# �e�L�X�g�G���A�̏�������
my $textarea_input = $textarea_first_input;
$textarea_input =~ s/<br>/\n/g;

if ($job ne "new") {  }
elsif ($job eq "new") { 

$print .= "��<input type=\"text\" name=\"sub\" size=\"14\" value=\"$resub\" maxlength=\"50\"$xclose><br$xclose>"; }

# ���\���A�\�͕\��
if($job eq "new"){ require "${int_dir}part_sexvio.pl"; &sexvio_form(); }

# ���̓{�b�N�X
$print .= qq(��<input type="text" name="name" size="12" value="$cnam"$xclose>);

my(@color) = Mebius::Init::Color(undef);
 
# �����F
$print .= qq(�F<select name="color">);
	foreach(@color) {
		my($name,$code) = split(/=/);
			if($code eq $ccolor) { $print .= qq(<option value="$code"$main::parts{'selected'}>$name</option>\n); }
			else { $print .= qq(<option value="$code">$name</option>\n); }
	}
$print .= qq(</select>);

# ���̓{�b�N�X
$print .= qq(
<br$xclose><textarea cols="25" rows="5" name="comment">$textarea_input</textarea><br$xclose>
$input_upload
$viocheck$sexcheck
<span style="font-size:small;">
);


my $form_parts = new Mebius::BBS::Form;

	# Up �`�F�b�N�{�b�N�X
	if ($job ne "new") {

		$print .= $form_parts->thread_up({ MobileView => 1 , from_encoding => "sjis" });
			#if ($cup != 2) { print"<input type=\"checkbox\" name=\"up\" value=\"1\"$checked$xclose>����"; }
			#else{ print"<input type=\"checkbox\" name=\"up\" value=\"1\"$xclose>����";}
	}
	else{
		$print .= $form_parts->thread_up({ Hidden => 1 , MobileView => 1 , from_encoding => "sjis" });
			#if ($cup != 2) { print"<input type=\"hidden\" name=\"up\" value=\"1\"$xclose>"; }
	}



	# TOP�V���{�b�N�X
	#if($secret_mode){ $print .= qq(<input type="hidden" name="news" value="$cnews"$xclose>); }
	#else{
	#if($cnews eq "2"){ $print .= qq(<input type="checkbox" name="news" value="1"$xclose>�V��); }
	#else{ $print .= qq(<input type="checkbox" name="news" value="1"$checked$xclose>�V��); }
	#}

	# �����̌��J
	#$print .= Mebius::BBS::id_history_input_parts({ from_encoding => "sjis" });

	# �A�J�E���g�ւ̃����N
	$print .= $form_parts->account_link({ from_encoding => "sjis" , MobileView => 1 });
	$print .= $form_parts->news({ from_encoding => "sjis" , MobileView => 1 });

if ($job ne "new") { $print .= "<input type=\"hidden\" name=\"res\" value=\"$in{'no'}\"$xclose>"; }

$print .= qq(
</span>
<br$main::xclose>
<div style="text-align:right;">
<input type="submit" name="preview" value="*�m�F" accesskey="*"$xclose>
<input type="submit" value="#���M" accesskey="#"$xclose>
<input type="hidden" name="mode" value="regist"$xclose>
<input type="hidden" name="moto" value="$realmoto"$xclose>
<input type="hidden" name="k" value="1"$xclose>
<input type="hidden" name="access_time" value="$time"$xclose>
<input type="hidden" name="resnum" value="$next_resnumber"$xclose>
$backurl_input
</div>
</div></form>
);

		return $print;
}


1;
