
use Mebius::BBS::Form;
package main;

#-----------------------------------------------------------
# �g�є� �v���r���[
#-----------------------------------------------------------
sub regist_mobile_rerror{

# �錾
my($fast_error) = @_;
my(@kcolor,$kback_link_tell);
my($print);

my(%emoji) = Mebius::Emoji;
my($emoji_shift_jis) = Mebius::Encoding::hash_to_shift_jis(\%emoji);

# �G���[���A�����b�N
if($lockflag) { &unlock($lockflag); }


# �^�C�g��
$sub_title = qq(���e | $title);

# �߂��
if($in{'res'} ne "") { $kback_link_tell ="$in{'res'}.html"; } else { $kback_link_tell ="kform.html"; }


#�h�c�C�g���b�v�̑���
my $trip = "���g���b�v" if($enctrip);
my $id = "��$encid" if($encid);

if($i_sub){ $ip_sub=""; }
$pre_res = $in{'pre_res'} + 1;

	# ���������N
	if($main::bbs{'concept'} =~ /Sousaku-mode/){ ($i_com) = &kauto_link("Thread Omit Preview Loose",$i_com,$main::in{'res'}); }
	else{ ($i_com) = &kauto_link("Thread Omit Preview",$i_com,$main::in{'res'}); }

	if ($in{'res'} eq ""){ $pre_com="$i_sub<br$xclose><br$xclose>0.$i_handle$trip<br$xclose><br$xclose>$i_com<br$xclose>"; }
	else{ $pre_com = "$pre_res.$i_handle$trip<br$xclose><br$xclose>$i_com<br$xclose>"; }

	# �v���r���[�̕\�����e�i�ԐM���j-----
	if($in{'preview'}){

		if(!$e_com){ $pleasepost_text = qq(<br$xclose>�ǂ����<input type="submit" value="#���M"$xclose>���Ă��������B); }

		# �\��
		my($gold);
		if($cgold eq ""){ $gold = "0��"; }
		else{ $gold = "$cgold��"; }
		$pre_body .= qq(<div style="background:#9ee;$ktextalign_center_in$kborder_top_in">�\\��</div>);
		$pre_body .= qq(<div style="margin:0.3em 0em;">���e $smlength���� �� );
		$pre_body .= qq( <img src="/pct/icon/gold2.gif" alt="����" title="����"$xclose> $gold);
		$pre_body .= qq(<br$main::xclose><span style="color:#077;">������`���[�W $nextcharge_minsec $kfight_text1</span></div>);

		# �v���r���[
		$pre_body .= qq(<div style="background:#ddf;$ktextalign_center_in$kborder_top_in">�v���r���[(�����e)</div>);

		# �V�K���e
		if($in{'res'} eq ""){
			$pre_body .= qq(<div style="margin:0.3em 0em;">);
			$pre_body .= qq($i_sub<br$xclose><br$xclose>0.$i_handle$trip$id<br$xclose>);
			$pre_body .= qq(<span style="color:$in{'color'};">$i_com</span><br$xclose>$date);
			$pre_body .= qq(</div>);
		}

		# ���X���e
		else{
			$pre_body .= qq(<div style="margin:0.3em 0em;color:$in{'color'}">);
			$pre_body .= qq($i_handle$trip$id<br$xclose>);
			$pre_body .= qq($i_com<br$xclose>$date$pleasepost_text);
			$pre_body .= qq(</div>);
		}
	}

# ���e�O�`�F�b�N
if($e_com){

if(!$strong_emd) { $pleasechange_text = qq(��$emoji_shift_jis->{'number5'}<a href="#ARESFORM">�ҏW̫��</a>�ŏC���o���܂��B); }

$error_body = qq(
<div style="background:#fbb;$ktextalign_center_in$kborder_top_in">���e�G���[</div>
<div style="color:#f00;font-size:small;">
$e_com
$pleasechange_text
</div>
);
}


$in{'comment'} =~ s/<br>/\n/g;

# �摜�Y�t�G���A
if($main::bbs{'concept'} =~ /Upload-mode/){ require "${int_dir}def_secret.pl"; &upload_setup("k"); }

if($fast_error){ $fast_error = qq(<strong style="color:#f00;">����G���[�F</strong> $fast_error<hr$xclose>); }
my($allview) = qq($fast_error $error_body $pre_body $alert_body);
$allview =~ s/<br>/<br$xclose>/g;

$print .= qq(
<form action="$script" method="post" name="rerror"$formtype$sikibetu><div>
$allview
);

if ($in{'res'} ne "") { $print .= qq(<input type="hidden" name="res" value="$in{'res'}"$xclose>\n); }

$print .= qq(<div style="background:#9f9;$ktextalign_center_in$kborder_top_in">);
$print .= qq($emoji_shift_jis->{'number5'}<a href="#ARESFORM" id="ARESFORM" accesskey="5">�ҏW</a>$emoji_shift_jis->{'write'});
$print .= qq(</div>);

if ($in{'res'} eq "") {
$print .= <<"EOM"
��<input type="text" name="sub" class="input" size="14" value="$in{'sub'}" maxlength="50"$xclose><br$xclose>
EOM
}

# MAX-LENGTH
my $maxlength_name = qq( maxlength="50");

$print .= qq(�M��<input type="text" name="name" size="14" class="input" value="$in{'name'}"$maxlength_name$xclose>);

# �����F

my(@color) = Mebius::Init::Color();

$print .= qq(�F<select name="color">);
	foreach(@color) {
		my($name,$code) = split(/=/);
			if($code eq $in{'color'}) { $print .= qq(<option value="$code" style="color:$code;"$main::parts{'selected'}>$name</option>\n); }
			else { $print .= qq(<option value="$code" style="color:$code;">$name</option>\n); }
	}

$print .= qq(</select>);
$print .= qq(<br$xclose>);

# ���e�{�^��
$submit_botton = qq(<input type="submit" name="preview" value="*�m�F" accesskey="*"$xclose>
<input type="submit" value="#���M" accesskey="#"$xclose>);

# ���\���A�\�͕\���̃`�F�b�N
if($i_res eq ""){ require "${int_dir}part_sexvio.pl"; &sexvio_form(); }

# �e�L�X�g�G���A�̓��e
my $intextarea = qq($in{'comment'});
$intextarea =~ s/\[REFERER\]//g;

# �e�L�X�g�G���A
$print .= qq(
<textarea cols="25" rows="5" name="comment">$intextarea</textarea><br$xclose>
$input_upload
$viocheck$sexcheck
<span style="font-size:small;">
);


my $form_parts = new Mebius::BBS::Form;

	# Up �{�b�N�X
	if ($in{'res'} ne "") {
		$print .= ($form_parts->thread_up({ MobileView => 1 , from_encoding => "sjis" }));
		#if ($in{'up'} == 1) { print"<input type=\"checkbox\" name=\"up\" value=\"1\"$checked$xclose>����"; }
		#else{ print"<input type=\"checkbox\" name=\"up\" value=\"1\"$xclose>����";}
	}
	elsif($in{'up'} == 1) {
		$print .= ($form_parts->thread_up({ Hidden => 1 , MobileView => 1 , from_encoding => "sjis" }));
	}

# TOP�V���{�b�N�X
#if($secret_mode){ $print .= qq(<input type="hidden" name="news" value="$cnews"$xclose>); }
#else{
#if($in{'news'}){ $print .= qq(<input type="checkbox" name="news" value="1"$checked$xclose>�V��); }
#else{ $print .= qq(<input type="checkbox" name="news" value="1"$xclose>�V��); }
#}

	# ID����
	#$print .= (Mebius::BBS::id_history_input_parts({ from_encoding => "sjis" }));

	# �A�J�E���g�ւ̃����N
	$print .= ($form_parts->account_link({ from_encoding => "sjis" , MobileView => 1 }));

$print .= qq(
</span>
<div style="text-align:right;">
$submit_botton
</div>
<input type="hidden" name="mode" value="regist"$xclose>
<input type="hidden" name="moto" value="$realmoto"$xclose>
<input type="hidden" name="pre_res" value="$in{'pre_res'}"$xclose>
<input type="hidden" name="k" value="1"$xclose>
<input type="hidden" name="access_time" value="$in{'access_time'}"$xclose>
<input type="hidden" name="resnum" value="$in{'resnum'}"$xclose>
$main::backurl_input
</div>
</form>
);


Mebius::Template::gzip_and_print_all({},$print);


exit; 

}

#-------------------------------------------------
# �g�є� ���e���̃����N����
#-------------------------------------------------
sub reist_autolink_mobile {
local($msg) = @_;

($msg) = Mebius::auto_link($msg);




$msg;
}



1;
