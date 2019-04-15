
package main;

#-----------------------------------------------------------
# �}�C�y�[�W
#-----------------------------------------------------------
sub main_mypage{

# �Ǐ���
my($bbs,$back,$bbs_link,$back_link,$follow_line);
my($oneline,$message_line,$edit_form);
our(%in,$backurl,$backurl_link,$kflag,$noindex_flag);
my($q) = Mebius::query_state();
my $html = new Mebius::HTML;
my $history = new Mebius::History;

# �����悯
$noindex_flag = 1;

# �g�у��[�h ( �������Ȃ��B &backurl(); ���O�ɕK�v )
# �g�уA�C�e��
if($main::device{'type'} eq "Mobile"){ kget_items(""); }

# ���O�ő啶����
$maxnam = 10;

# �����T�C�Y�̎��
@moji_size = (60,70,80,90,100,110,120,130,140,150);

# ��ʕ��̎��
@width_size = (50,60,70,80,85,90,95,100);

# CSS��`
$css_text .= qq(
h2{display:inline;font-size:120%;clear:both;}
div.h2{background:#bbb;padding:0.3em 0.5em;margin:1em 0em;}
div.domain_list{background:tranceparent;color:#080;font-size:90%;text-align:right;margin:0.5em;}
div.RESHISTORY{background:#9e9;}
div.FOLLOW{background:#7cf;}
div.MESSAGE{background:#ff5;}
div.EDIT{background:#7bb;}
div.RECORD{background:#fbb;}
div.CERMAIL{background:#fa4;}
div.CHECKHISTORY{background:#acf;}
hr{margin:1em 0em 1em 0em;}
li{line-height:1.5em;}
.alert{color:#f00;font-size:80%;}
.navi_link{font-size:90%;}
ul{margin:1em 0em;}
div.history_flow{text-align:right;margin:1em 0em;}
td{vertical-align:top;}
div.fillter_guide{padding:1em;margin:1em 0.5em;font-size:80%;border:solid 1px #080;line-height:1.4em;}
i{background:#99f;margin:0em 0.5em 0em 0em;}
);

	# �X�}�t�H��CSS
	if($main::device{'smart_flag'}){
		$main::css_text .= qq(div.page1{padding:0.5em;border:}\n);
		
	}
	# ����ȊO��CSS
	else{
		$main::css_text .= qq(.tdleft{white-space:nowrap;}\n);
		$main::css_text .= qq(input.select1,select.select1{width:15em;}\n);
		$main::css_text .= qq(div.page1{padding:2em 2em;border:solid 1px #555;}\n);
	}

# �^�C�g����`
my $sub_title = "�}�C�y�[�W - $server_domain";
#$head_link1 = qq( &gt; <a href="http://aurasoul.mb2.jp/">�ʏ��</a> | <a href="http://mb2.jp/">��y��</a> );
$head_link3 = " &gt; �}�C�y�[�W";

	# �ύX����
	if($in{'csubmit'}){ &mysubmit(); }
	elsif($in{'type'} eq "control_history"){ control_new_system_history_mypage(); }

# ���M��
$my_action = "./";

# ���[���A�h���X�̔F�؃`�F�b�N
#local($cermail_td) = email_form_mypage();

# �h���C���؂�ւ������N
my($domain_list) = main_mypage_domainlist();

#<a href="#FOLLOW">���t�H���[</a> -

	# �i�r�Q�[�V���������N
	if(!$kflag){
		$navi_link .= qq(
		<div class="navi_link">
		<a href="/">�s�n�o�y�[�W</a> - );
			if($backurl){ $navi_link .= qq($backurl_link - ); }
	}
	else{ $navi_link .= qq(<div style="font-size:small;">); }
$navi_link .= qq(<a href="./?mode=settings">�ݒ�</a> -\n);
	if(!$kflag){ $navi_link .= qq(<a href="#CERMAIL">�����m�点���[��</a> -\n); }
$navi_link .= qq(<a href="#RECORD">������</a>\n);
	if(!$kflag){
		$navi_link .= qq(�@<span class="red">/�@���� $thisyear�N $thismonth��$today�� $thishour��$thismin�� </span>);
	}
$navi_link .= qq(</div>);


# ���e�������擾
#my($reshistory_line) = main_mypage_reshistory();
my $reshistory_line .= qq(<div class="h2 RESHISTORY"><h2 id="RESHISTORY">���e����</h2></div>);
$reshistory_line .= qq(<form action="" method="post">);
$reshistory_line .= $html->input("hidden","mode","my");
$reshistory_line .= $html->input("hidden","type","control_history");
$reshistory_line .= shift_jis($history->my_history_index());
$reshistory_line .= qq(<div class="right"><input type="submit" value="�폜"></div>);
$reshistory_line .= qq(</form>);

	# ���m�点���[���o�^���X�g���擾
	if($cookie && !$kflag){ getlist_cermail(); }

# ����܂ł̐��т��擾
get_myrecord();

# HTML
my $print .= qq(<div class="page1">);

	# �ݒ�ύX�t�H�[�����擾
	if($q->param('mode') eq "settings"){
			$print .= qq(	<h1$main::kfontsize_h1>�ݒ�</h1>);
			my($edit_form) = get_editform();
			$print .= $edit_form;
	} else {

			# HTML
			if(!$kflag){
				$print .= qq(	<h1$main::kfontsize_h1>�}�C�y�[�W</h1>$navi_link);
			}

			if($kflag){
				$print .= qq(<h1$main::kfontsize_h1>�}�C�y�[�W</h1>);
			}

			# �e�탉�C���\�� ( �f�X�N�g�b�v )
			if(!$kflag){
				$print .= qq(
				$reshistory_line
				$follow_line
				$mylist
				$list_cermail
				$message_line
				$myrecord
				$edit_form
				);
			}

			# �e�탉�C���\�� ( ���o�C�� )
			else{
				$print .= qq(
				$navi_link
				$reshistory_line
				$follow_line
				$mylist
				$list_cermail
				$message_line
				$myrecord
				$edit_form
				);
			}

	}

# �Ǘ��҂ɃN�b�L�[�̗v�f��\��
($print) .= main_mypage_cookielist();

$print .= qq(<br$xclose></div>);

# �t�b�^
Mebius::Template::gzip_and_print_all({ Title => $sub_title },$print);

exit;

}

#-----------------------------------------------------------
# ���e������\��
#-----------------------------------------------------------
sub main_mypage_reshistory{

# �錾
my($line,$maxview,$none,$flow,$postbuf_enc);
our(%in,$kflag,$postbuf);

# �\���ő吔
$maxview = 20;
	if($kflag){ $maxview = 5; }
	if($in{'viewmax'}){ $maxview = 50; }
	if(!Mebius::Server::bbs_server_judge()){ return(); }

# ���e�������擾
require "${main::int_dir}part_history.pl";
my($none,$none,$res_history_line,$res_history_flow) = &get_reshistory("INDEX THREAD My-file Mypage-view Allow-renew-status",undef,undef,undef,$maxview);
my($none,$none,$crap_history_line,$crap_history_flow) = &get_reshistory("INDEX THREAD Crap-file My-file Mypage-view Allow-renew-status",undef,undef,undef,$maxview);
my($none,$none,$check_history_line,$check_history_flow) = &get_reshistory("INDEX THREAD Check-file My-file Mypage-view Allow-renew-status",undef,undef,undef,$maxview);

# �����N��
$postbuf_enc = $postbuf;
$postbuf_enc =~ s/&/&amp;/g;

	# ���`
	if($res_history_line){

		my($domain_list) = &main_mypage_domainlist("RESHISTORY");

			if($res_history_flow){
				$res_history_line = qq(<div class="h2 RESHISTORY"><h2 id="RESHISTORY"$main::kfontsize_h2><a href="./?$main::postbuf_query_esc&amp;viewmax=1$backurl_query_enc#RESHISTORY">���e����</a></h2></div>$res_history_line);
				$res_history_line .= qq(<div class="history_flow"><a href="./?$main::postbuf_query_esc&amp;viewmax=1$backurl_query_enc#RESHISTORY">��������\\������</a></div>$domain_list);
			}
			else{
				$res_history_line = qq(<div class="h2 RESHISTORY"><h2 id="RESHISTORY"$main::kfontsize_h2>���e����</h2></div>$res_history_line$domain_list);
			}
	}

	# ���`
	if($crap_history_line){

		my($domain_list) = &main_mypage_domainlist("CRAPHISTORY");

			if($crap_history_flow){
				$crap_history_line = qq(<div class="h2 CRAPHISTORY"><h2 id="CRAPHISTORY"$main::kfontsize_h2><a href="./?$main::postbuf_query_esc&amp;viewmax=1$backurl_query_enc#CRAPHISTORY">���e����</a></h2></div>$line);
				$crap_history_line .= qq(<div class="history_flow"><a href="./?$main::postbuf_query_esc&amp;viewmax=1$backurl_query_enc#CRAPHISTORY">��������\\������</a></div>$domain_list);
			}
			else{
				$crap_history_line = qq(<div class="h2 CRAPHISTORY"><h2 id="CRAPHISTORY"$main::kfontsize_h2>�����ˁI����</h2></div>$crap_history_line$domain_list);
			}
	}

	# ���`
	if($check_history_line){

		my($domain_list) = &main_mypage_domainlist("CHECKHISTORY");

			if($check_history_flow){
				$check_history_line = qq(<div class="h2 CHECKHISTORY"><h2 id="CHECKHISTORY"$main::kfontsize_h2><a href="./?$main::postbuf_query_esc&amp;viewmax=1$backurl_query_enc#CHECKHISTORY">���e����</a></h2></div>$line);
				$check_history_line .= qq(<div class="history_flow"><a href="./?$main::postbuf_query_esc&amp;viewmax=1$backurl_query_enc#CHECKHISTORY">��������\\������</a></div>$domain_list);
			}
			else{
				$check_history_line = qq(<div class="h2 CHECKHISTORY"><h2 id="CHECKHISTORY"$main::kfontsize_h2>�`�F�b�N����</h2></div>$check_history_line$domain_list);
			}
	}


$line = $res_history_line . $crap_history_line . $check_history_line;

return($line);

}

#-----------------------------------------------------------
# �ݒ�ύX�t�H�[�����擾
#-----------------------------------------------------------
sub get_editform{

my($line,$record_crireki_checkbox);
my($checked_end,$checked_start,$chandle,$ctrip_value);

my($domain_list) = &main_mypage_domainlist("EDIT");

# ���O�ƃg���b�v�𕪂���
my($handle_value,$trip_value) = split(/#/, $main::cnam,2);

$line .= qq(
<div class="h2 EDIT"><h2 id="EDIT"$main::kfontsize_h2>�f���̐ݒ�</h2></div>
<form action="$my_action" method="post"$sikibetu>
<div>
<input type="hidden" name="mode" value="my"$xclose>
$backurl_input
<table style="border-style:none;">
);

# �[���؂�ւ��t�H�[��
my($device_switch_form) = shift_jis(get_device_type_form_mypage());
$line .= $device_switch_form;

# �M����
$line .= qq(

<tr title="���Ȃ��̃n���h���l�[����ݒ肵�Ă��������B">
<td class="tdleft"><label for="cnam"><strong>�M��</strong></label></td>
<td><input type="text" name="cnam" value="$handle_value" size="20" maxlength="20" class="select1" id="cnam"$xclose>
�i�{���֎~�A�S�p10�����܂Łj</td>
</tr>

<tr title="�U�Җh�~�ł��B�D���ȕ��������͂��Ă��������B">
<td><label for="ctrip"><strong><a href="${guide_url}%A5%C8%A5%EA%A5%C3%A5%D7" class="blank" target="_blank" placeholder="���">�g���b�v�̑f</a></strong></label></td><td>
<input type="text" name="ctrip" value="$trip_value" size="20" maxlength="20" class="select1" id="ctrip"$xclose>
�i���p20�����A�S�p10�����܂ŁB��������ɂ������̂��j
</td></tr>
);

# �����A�h�F��
$line .= qq($cermail_td);

# �N��ݒ�
($line) .= &age_form();

# �����ȗ��t�H�[��
($line).= &get_ccutform();

# �摜�I���I�t�ؑփt�H�[��
#($line) .= &get_imagelink_form_mypage();

	# �����T�C�Y
	if(!$kflag){
		$line .= qq(<tr><td><label for="cfontsize"><strong>�����T�C�Y</strong></label></td><td>
		<select name="cfontsize" id="cfontsize" class="select1">);

		$select_cfontsize = $cfontsize;
		if(!$cfontsize){$select_cfontsize = 100;}
		foreach(@moji_size){
		if($select_cfontsize == $_){ $line .= qq(<option value="$_"$selected>�����T�C�Y $_��</option>\n); }
		else{ $line .= qq(<option value="$_">�����T�C�Y $_��</option>\n); }
		}
		$line .= qq(</select></td></tr>);
	}


	# ���e��̃W�����v
	if(!$kflag && 0){
		my @cposted = ("0","1","2","3","4","5","6","7","8","9","10","15","20","25","30","45","60");
		$line .= qq(<tr title="�f���ɏ������񂾌�ɁA�����W�����v����b����ݒ肵�܂��B"><td class="tdleft"><label for="cposted"><strong>���e��̃W�����v</strong></label></td><td><select name="cposted" id="cposted" class="select1">);
		foreach (@cposted){
		if(($cposted eq "" || $cposted eq "default") && $_ == 3){ $line .= qq(<option value="default"$selected>$_�b��ɃW�����v (�f�t�H���g)</option>\n); }
		elsif($_ eq $cposted){ $line .= qq(<option value="$_"$selected>$_�b��ɃW�����v</option>\n); }
		else{ $line .= qq(<option value="$_">$_�b��ɃW�����v</option>\n); }
		}
		if($cposted eq "direct"){ $line .= qq(<option value="direct"$selected>�u���ɃW�����v</option>\n); }
		else{ $line .= qq(<option value="direct">�u���ɃW�����v</option>\n); }
		if($cposted eq "auto"){ $line .= qq(<option value="auto"$selected>�`���[�W�I�����ɃW�����v</option>\n); }
		else{ $line .= qq(<option value="auto">�`���[�W�I�����ɃW�����v</option>\n); }
		if($cposted eq "off"){ $line .= qq(<option value="off"$selected>�W�����v���Ȃ�</option>\n); }
		else{ $line .= qq(<option value="off">�W�����v���Ȃ�</option>\n); }
		$line .= qq(</select></td></tr>);
	}

# �t�H���[�@�\
$line .= qq(<tr><td><label for="cfollow"><strong>�t�H���[�@�\\</strong></label></td><td><select name="cfollow" id="cfollow" class="select1">);
my($selected1,$selected2);
$selected1 = $selected;
if($cfollow eq "off"){ $selected2 = $selected; $selected1 = ""; }
$line .= qq(
<option value="on"$selected1>�t�H���[�@�\\���g��</option>
<option value="off"$selected2>�t�H���[�@�\\���g��Ȃ�</option>
);
$line .= qq(</select>�@<span class="guide" style="font-size:small;">���h�g��Ȃ��h��I�Ԃƍ��̃t�H���[���e�����Z�b�g����܂��B</span>
</td></tr>);


# ���e�����̑I��
$record_crireki_checkbox .= qq(<select name="record_crireki" id="record_crireki">\n);
	if($crireki eq "off"){ $checked_end = $main::parts{'selected'}; }
	else{ $checked_start = $main::parts{'selected'}; }
		$record_crireki_checkbox .= qq(<option value="start"$checked_start>�L�^����</option>\n);
		$record_crireki_checkbox .= qq(<option value="off"$checked_end>�L�^���Ȃ�</option>\n);
		$record_crireki_checkbox .= qq(<option value="reset">�L�^�����Z�b�g����</option>\n);
		$record_crireki_checkbox .= qq(</select>\n);

# ����
$record_crireki_checkbox .= qq(<span style="color:#080;" class="guide">�����J�p�̗���(�A�J�E���g/ID/�g���b�v��)�ɂ͔��f����܂���B(<a href="${main::guide_url}%A5%C8%A5%EA%A5%C3%A5%D7" target="_blank" class="blank">���g���b�v�K�C�h</a>)</span>);



# ���e����
$line .= qq(
<tr>
<td><label for="record_crireki"><strong>���e����</strong></label></td>
<td>
$record_crireki_checkbox
$rireli_line
</td>
</tr>
);


# �ȈՃt�B���^�t�H�[��
($line) .= &get_fillter_form_mypage();

# �ύX����{�^���A�t�H�[���I��� -----

$line .= qq(
<tr><td></td><td>
<input type="hidden" name="csubmit" value="1"$xclose>
<input type="submit" value="���̓��e�ŕύX����" class="isubmit"$xclose>
<input type="submit" name="backurl_on" value="�ύX���Č��̃y�[�W�ɖ߂�" class="isubmit"$xclose>

$backurl_checkbox
</td></tr></table>
</div></form>
$domain_list
);



return($line);

}

#-----------------------------------------------------------
# �g�єł̕������ȗ�
#-----------------------------------------------------------
sub get_ccutform{

my($line,$select);
my($selected1,$selected1_5,$selected0,$selected2,$selected3);

	# �o�b��
	if($main::device{'type'} ne "Mobile"){
			if($ccut eq "1" || $ccut eq ""){ $line .= qq(<input type="hidden" name="ccut" value="1">); }
			else{ $line .= qq(<input type="hidden" name="ccut" value="$ccut">); }
		return($line); 
	}

	if($ccut eq "1" || $ccut eq ""){ $selected1 = $selected; }
	if($ccut eq "0"){ $selected0 = $selected; }
	if($ccut eq "1.5"){ $selected1_5 = $selected; }
	if($ccut eq "2"){ $selected2 = $selected; }
	if($ccut eq "3"){ $selected3 = $selected; }

$select .= qq(<select name="ccut" class="select1">\n);
$select .= qq(<option value="1"$selected1>�ȗ�����(����)</option>);
$select .= qq(<option value="1.5"$selected1_5>�ȗ�����(1.5�{)</option>);
$select .= qq(<option value="2"$selected2>�ȗ�����(2�{)</option>);
$select .= qq(<option value="3"$selected3>�ȗ�����(3�{)</option>);
$select .= qq(<option value="0"$selected0>�ȗ����Ȃ�</option>);
$select .= qq(</select>);

$line = qq(
<tr><td><strong>���X�ȗ�</strong></td><td>$select<span style="font-size:small;color:#f00;">���y�[�W���r�؂��ꍇ�́u�ȗ�����(����)�v��I��ł��������B</span></td></tr>
);

return($line);

}

#-----------------------------------------------------------
# �摜�\���̃I���I�t�؂�ւ��t�H�[��
#-----------------------------------------------------------
sub get_imagelink_form_mypage{

my($line,$select);
my($selected_on,$selected_hide);
our($cimage_link,$selected);

# �I��
if($cimage_link eq "hide"){ $selected_hide = $selected; }
if($cimage_link eq "on"){ $selected_on = $selected; }

$select .= qq(<select name="cimage_link" id="cimage_link" class="select1">\n);
$select .= qq(<option value="on"$selected_on>���ʂɕ\\������</option>);
$select .= qq(<option value="hide"$selected_hide>�摜���B��</option>);
$select .= qq(</select>);

$line = qq(
<tr><td><label for="cimage_link"><strong>���G�����G�̕\\��</strong></label></td><td>$select</td></tr>
);

return($line);

}

use strict;


#-----------------------------------------------------------
# �N��ݒ�t�H�[��
#-----------------------------------------------------------
sub age_form{

my($line,$i);
our($cage,$disabled,$selected,$xclose,$thisyear);

# �N��ݒ�ς݂̏ꍇ
if($cage && 1 == 0){
$line .= qq(<tr><td><label for="cage"><strong>���N(����J)</strong></label></td>);
$line .= qq(<td><select name="cage" class="select1" id="cage"$disabled>\n);
$line .= qq(<option value="$cage">$cage �N���܂�</option>\n);
$line .= qq(</select></td></tr>);
$line .= qq(<input type="hidden" name="cage" value="$cage"$xclose>);
}


# �N��ݒ�̏ꍇ
else{
my($i);
$line .= qq(<tr><td><label for="cage"><strong>���N(����J)</strong></label></td>);
$line .= qq(<td><select name="cage" class="select1" id="cage">\n<option value="0"> ���I��</option>\n);
$i = $thisyear;
for(1..130){
$i--;
if($i eq $cage){ $line .= qq(<option value="$i"$selected>$i�N ���܂�</option>\n); }
else{ $line .= qq(<option value="$i">$i�N ���܂�</option>\n); }
}


$line .= qq(</select></td></tr>);
}

return($line);

}


no strict;


#-----------------------------------------------------------
# �ȈՃt�B���^
#-----------------------------------------------------------
sub get_fillter_form_mypage{

# �錾
my($type) = @_;
my($line,$id_fillter_view,$account_fillter_view);

# �������͒l
my $cfillter_id_inputed = $main::cfillter_id;
my $cfillter_account_inputed = $main::cfillter_account;

	# ���݂̃t�B���^�ݒ��W�J
	foreach(split(/\s/,$main::cfillter_id)){
		$id_fillter_view .= qq(<i>��$_</i>\n);
	}

$line .= qq(<tr><td><label for="cfillter_id"><strong>ID�t�B���^</strong></label></td>);
$line .= qq(<td>);
$line .= qq(<input type="text" name="cfillter_id" id="cfillter_id" value="$cfillter_id_inputed" style="width:50%;"$main::xclose>);
if($id_fillter_view){ $line .= qq(<br$main::xclose>$id_fillter_view); }
$line .= qq(</td>);
$line .= qq(</tr>);


	# ���݂̃t�B���^�ݒ��W�J
	foreach(split(/\s/,$main::cfillter_account)){
		$account_fillter_view .= qq(<a href="${main::auth_url}$_/">$_</a>\n);
	}


$line .= qq(<tr><td><label for="cfillter_account"><strong>�A�J�E���g�t�B���^</strong></label></td>);
$line .= qq(<td>);
$line .= qq( <input type="text" name="cfillter_account" id="cfillter_account" value="$cfillter_account_inputed" style="width:50%;"$main::xclose>);
	if($account_fillter_view){ $line .= qq(<br$main::xclose>$account_fillter_view); }
$line .= qq(<div class="fillter_guide"><span style="color:#080;">�f���̋L���ŁA���胆�[�U�[�̓��e���\\���ɏo���܂��B�i����ɂ͒ʒm����܂���j);
$line .= qq(<br$main::xclose>���ꂼ��h�c/�A�J�E���g������͂��Ă��������B�����w�肷��ꍇ�́A�X�y�[�X�ŋ�؂��Ă��������B );
$line .= qq(</span></div>);
$line .= qq(</td>);
$line .= qq(</tr>);

return($line);


}

use strict;

#-----------------------------------------------------------
# ���b�Z�[�W���擾 (��g�p)
#-----------------------------------------------------------
sub getlist_message{

# �錾
my($oneline,$message_line,$maxview_line,$index_flow,$h2,$flow_href,$moreview_link);

# �\���s����ݒ�
$maxview_line = 5;
if($main::in{'viewmax'}){ $maxview_line = 100; }

# �h���C�����X�g���擾
my($domain_list) = &main_mypage_domainlist("MESSAGE");

	# ���b�Z�[�W���擾 �i�A�J�E���g�j
	if($main::pmfile){
		my($plustype) = " CHECK RENEW" if($main::in{'message_check'});
		require "${main::int_dir}part_idcheck.pl";
		($message_line,$index_flow) = &call_savedata_message("ACCOUNT INDEX $plustype",$main::pmfile,"","",$maxview_line);
	}

	# ���b�Z�[�W���擾 �i�g�т̌ő̎��ʔԍ��j
	elsif($main::kaccess_one){
		my($plustype) = " CHECK RENEW" if($main::in{'message_check'});
		require "${main::int_dir}part_idcheck.pl";
		($oneline,$message_line) = &call_savedata_message("MOBILE INDEX $plustype",$main::kaccess_one,$main::k_access,"","",$maxview_line);
	}

	# flow ���Ă���ꍇ�̐��`
	if($message_line && $index_flow && !$main::in{'viewmax'}){
$flow_href = qq(./?$main::postbuf_query_esc&amp;viewmax=1$main::backurl_query_enc#MESSAGE);
$h2 = qq(<h2 id="MESSAGE"$main::kfontsize_h2><a href="$flow_href">���b�Z�[�W</a></h2>);
$moreview_link = qq(<div class="flow"><a href="$flow_href">��������\\������</a></div>);
	}

	# flow���Ă��Ȃ��ꍇ�̐��`
	else{
$h2 = qq(<h2 id="MESSAGE"$main::kfontsize_h2>���b�Z�[�W</h2>);
	}

	# ���b�Z�[�W�s�̐��`
	if($message_line){
$message_line = qq(
<div class="h2 MESSAGE">$h2</div>
$message_line
$moreview_link
$domain_list
);
	}

# ���^�[��
return($message_line);

}

no strict;

#-----------------------------------------------------------
# ���m�点���[���̃��X�g���擾
#-----------------------------------------------------------
sub getlist_cermail{

# �Ǐ���
my($cancel_link,$FILE);
my($myaddress) = Mebius::my_address();

# �t�@�C����`
my($file) = Mebius::Encode(undef,$myaddress->{'address'});

	# �����A�h���̃L�����A�t�@�C�����J��
	if($file){

		open($FILE,"<","${main::int_dir}_address/$file/bbs_thread_career.dat");
				while(<$FILE>){
					my($link1,$subject_view);
					chomp;
					my($no2,$moto2,$subject_while,$bbs_title_while) = split(/<>/,$_);
					my($res,$lasttime);# = &get_thread($no2,$moto2,$title);
					$list_cermail .= qq(<li>);
						if($subject_while){ $subject_view = $subject_while; } else { $subject_view = "$moto2-$no2"; }

					$list_cermail .= qq(<a href="/_$moto2/$no2.html">$subject_view</a>);
						if($bbs_title_while){ $list_cermail .= qq( &lt; <a href="/_$moto2/">$bbs_title_while</a>); }
					$list_cermail .= qq( - <a href="/_$moto2/?mode=cermail&amp;type=cancel&amp;no=$no2&amp;my=1">�z�M����</a>);

				}
		close($FILE);
	}

# �h���C���؂�ւ������N���`
my($domain_list) = &main_mypage_domainlist("CERMAIL");

# ���e������ꍇ
if($list_cermail){
$list_cermail = qq(
<div class="h2 CERMAIL"><h2 id="CERMAIL"$main::kfontsize_h2>���m�点���[���o�^</h2></div>
<ul>
$list_cermail
</ul>
$domain_list
);
}
# ���e�������ꍇ
else{
$list_cermail = qq(
<div class="h2 CERMAIL"><h2 id="CERMAIL"$main::kfontsize_h2>���m�点���[���z�M</h2></div>
�o�^�͂܂�����܂���B
���[����z�M����ɂ� 
<strong><a href="http://aurasoul.mb2.jp/$kindex">�s�n�o�y�[�W</a> &gt; �D���Ȍf���� &gt; 
�D���ȋL�� &gt; <a href="http://aurasoul.mb2.jp/_qst/?mode=cermail&amp;no=2287">�u���m�点���[���v</a></strong> �̏��Ń����N��H���ĉ������B
$domain_list
);
}


}


#-------------------------------------------------
# �}�C�ݒ�ύX���̃G���[
#-------------------------------------------------

sub my_error{

my($error) = @_;


my $print = <<"EOM";
$error
<a href="?mode=my$backurl_query_enc">�߂�</a>
EOM

Mebius::Template::gzip_and_print_all({},$print);


exit;

}

#-----------------------------------------------------------
# ����܂ł̐��т��擾
#-----------------------------------------------------------
sub get_myrecord{

my($domain_list) = &main_mypage_domainlist("RECORD");

if($csoumoji && $csoutoukou >= 1){ $heikin = int($csoumoji / $csoutoukou); }

$csoumoji = int($csoumoji);

$hyo_heikin="���������撣��܂��傤";

if($heikin > 500) { $hyo_heikin = '�G�N�Z�����g�I'; }
elsif($heikin > 250) { $hyo_heikin = '�Ȃ��Ȃ��f���炵��'; }
elsif($heikin > 100) { $hyo_heikin = '�ǂ��o���ł�'; }
elsif($heikin > 50) { $hyo_heikin = '���ʂł�'; }

$myrecord .= qq(<div class="h2 RECORD"><h2 id ="RECORD"$main::kfontsize_h2>����܂ł̐���</h2></div>);

# �����N
my $ranking_link = qq(	<span class="guide">���A�J�E���g��<a href="${auth_url}">���O�C��</a>(�܂��͐V�K�o�^)����ƁA<a href="/_main/rankgold-p-1.html">�����L���O</a> �ɎQ���ł��܂��B</span> );
if($idcheck){ $ranking_link = qq( &lt; <a href="/_main/rankgold-p-1.html">�������L���O</a> &gt;); }

# �N�b�L�[����������A���e����\��
if($csoumoji){
$myrecord .= qq(
<ul>
<li>���݁F <strong class="red">$cgold��</strong> $ranking_link</li>
<li>�������݁F $csoutoukou��</li>
<li>���������F $csoumoji \��\��</li>
<li>���������ρF $heikin \��\��  �i$hyo_heikin�j</li>
</ul>
);
}

#�N�b�L�[�Ȃ��ꍇ
else{ $myrecord .= qq(���e�f�[�^�͂���܂���B);}

$myrecord .= qq($domain_list);

}



#-----------------------------------------------------------
# �h���C���؂�ւ������N��\��
#-----------------------------------------------------------
sub main_mypage_domainlist{

# �錾
my($type) = @_;
my($line,$i,$domain,$movetype);
our($server_domain,$backurl_query_enc,$backurl_link,@domains,%in);

	# ���`
	if($type){ $movetype = "#$type"; }


	# �h���C���������`
	if($in{'domain'}){ $domain = $in{'domain'}; }
	else{ $domain = $server_domain; }

	# �h���C����W�J
	foreach(@domains){
		$i++;
		if($i > 1){ $line	 .= qq( - ); }
			if($_ eq $server_domain){ $line .= qq(<strong>$_</strong>); }
			else{ $line .= qq(<a href="http://$_/_main/?mode=my&amp;domain=$domain$backurl_query_enc$movetype">$_</a>); }
	}

	# ���`
	#  class="$type " # CCC
	if($backurl){ $line = qq(<div class="domain_list right">$backurl_link - $line</div>); }
	else{ $line = qq(<div class="domain_list right">$line</div>); }

return($line);

}



#-----------------------------------------------------------
# �N�b�L�[�̗v�f���X�g
#-----------------------------------------------------------
sub main_mypage_cookielist{

my($my_account) = Mebius::my_account();
my ($self);

# �Ǘ��҂Ƀf�[�^�\��
if($my_account->{'master_flag'}){
$self = qq(
<div class="h2"><h2$main::kfontsize_h2>Cookie</h2></div>
<div style="color:#080;line-height:1.4em;">
�M���F $cnam | 
���e��W�����v�F $cposted | 
�h�c�̑f�F $cpwd | 
�����F�F $ccolor | 
�L���A�b�v�F $cup | 
�Z�b�g�񐔁F $ccount | 
�V�K���e�����F $cnew_time | 
���X�����F $cres_time | 
���݁F $cgold | 
���������F $csoumoji | 
���e�񐔁F $csoutoukou | 
�����T�C�Y�F $cfontsize | 
�t�H���[�F $cfollow | 
�{���F $cview | 
�Ǘ��ԍ��F $cnumber | 
���e�����F $crireki | 
���X�ȗ��F $ccut | 
�������ԁF $cmemo_time | 
�A�J�E���g�F $caccount | 
�p�X���[�h�F $cpass | 
�폜���ԁF $cdelres | 
�g�b�v�f�ځF $cnews | 
�N��F $cage | 
���[���A�h���X�F $cemail | 
�閧�F $csecret
</div>
);
}

$self;

}

#-------------------------------------------------
# URL�G���R�[�h
#-------------------------------------------------
sub url_enc {
local($_) = @_;

s/(\W)/'%' . unpack('H2', $1)/eg;
s/\s/+/g;
$_;
}

#-----------------------------------------------------------
# ���e�����̑���
#-----------------------------------------------------------
sub control_new_system_history_mypage{
my $self = shift;
my $history = new Mebius::History;
$history->query_to_control_history();
}


#-----------------------------------------------------------
# ���e�����̑���
#-----------------------------------------------------------
sub control_history_mypage{

# �錾
my($plustype);

	# �����t�@�C�����`
	if($main::in{'target_file'} eq "crap"){ $plustype .= qq( Crap-file); }
	elsif($main::in{'target_file'} eq "res"){ $plustype .= qq( Res-file); }
	elsif($main::in{'target_file'} eq "check"){ $plustype .= qq( Check-file); }
	else{ main::error("���삵�����Ώۂ�I��ł��������B"); }

		require "${int_dir}part_history.pl";

		&get_reshistory("ACCOUNT Control-history RENEW File-check-return My-file $plustype");
		&get_reshistory("CNUMBER Control-history RENEW File-check-return My-file $plustype");
		&get_reshistory("KACCESS_ONE Control-history RENEW File-check-return My-file $plustype");
		&get_reshistory("HOST Control-history RENEW File-check-return My-file $plustype");

#Mebius::Redirect("My-server-domain","${main::main_url}?mode=my");

}



#-----------------------------------------------------------
# �ύX����
#-----------------------------------------------------------
sub mysubmit{

# �錾
my($sendmail_flag,$error_flag,%address,%renew_address,%set_cookie);
my($my_cookie) = Mebius::my_cookie_main_logined();
our(%in);

# ID ���`
my($encid) = main::id();

	# �����[���A�h���X���`
	if($main::in{'cemail'}){

		# ���[���̏������`�F�b�N
		Mebius::mail_format("Error-view",$main::in{'cemail'});

		# �����A�h�t�@�C�����擾
		(%address) = Mebius::Email::address_file("Get-hash-detail Mypage",$main::in{'cemail'});

			# �����[���̔z�M�\����
			if($address{'myaddress_flag'}){

				# �Ǐ���
				my $start = $main::in{'email_allow_hour_start'};
				my $end = $main::in{'email_allow_hour_end'};

				# �z�M�����ԑт�ݒ�
				if(defined($start) && defined($end)){
						if($start =~ /\D/){ main::error("���[���z�M���ԑтɂ́A���p�������w�肵�Ă��������B"); }
						if($end =~ /\D/){ main::error("���[���z�M���ԑтɂ́A���p�������w�肵�Ă��������B"); }
						if($start > 24){ main::error("���[���z�M���ԑт́A24�����傫���͏o���܂���B"); }
						if($end > 24){ main::error("���[���z�M���ԑт́A24�����傫���͏o���܂���B"); }
						if($start > $end){ main::error("���[���z�M�̊J�n���Ԃ́A�I�����ԈȑO�ɐݒ肵�Ă��������B"); }
					$renew_address{'allow_hour'} = qq($start-$end);
				}
			}

		# �F�ؗp���[����z�M����ꍇ
		if($main::in{'send_cermail'} eq "send"){
			require "${int_dir}part_cermail.pl";
			($error_flag,$cermail_message) = Mebius::Email::SendCermail(undef,$main::in{'cemail'});
				if($error_flag){ main::error($error_flag); } 
		}

	}

	# �����A�h��Cookie�ɃZ�b�g
	if(exists $in{'cemail'}){
		$set_cookie{'email'} = $in{'cemail'};
	}

	# �F�؃��b�Z�[�W�𐮌`
	if($cermail_message){
		$cermail_message = qq(<hr$main::xclose>$cermail_message);
	}

	# �M������
	if(length($in{'cnam'}) > $maxnam*2){ &my_error("�M�����������܂��B"); }

	# �Z�b�g����N�b�L�[���`
	if(exists $in{'cfontsize'}){
		$set_cookie{'font_size'} = $in{'cfontsize'};
		$set_cookie{'font_size'} =~ s/\D//g;
	}

	# �M��
	if(exists $in{'cnam'}){
		$set_cookie{'name'} = $in{'cnam'};
	}

	# �g�єł̕��̓J�b�g
	if(exists $in{'ccut'}){
		$set_cookie{'omit_text'} = $in{'ccut'};
		$set_cookie{'omit_text'} =~ s/[^0-9\.]//g;
	}

	# �N��ݒ�
	if(exists $in{'cage'}){
		$set_cookie{'age'} = $in{'cage'};
		$set_cookie{'age'} =~ s/\D//g;
	}

	# ���e��̃W�����v
	if(exists $in{'cposted'}){
		$set_cookie{'refresh_second'} = $in{'cposted'};
		$set_cookie{'refresh_second'} =~ s/\W//;g
	}

	# �[���^�C�v
	if(exists $in{'cdevice_type'}){
			if($in{'cdevice_type'} eq "Auto"){ $set_cookie{'device_type'} = ""; }
			else{ $set_cookie{'device_type'} = $in{'cdevice_type'}; }
	}

	# ���G�����摜�\���̗L��
	#if(exists $in{'cimage_link'}){
	#	$cimage_link = $in{'cimage_link'};
	#	$cimage_link =~ s/\W//;g
	#}

	# �h�c�t�B���^
	if(exists $in{'cfillter_id'}){
		my($i,$max_fillter) = (0,5);
		$encid_hit = $encid;
		$encid_hit =~ s/^([A-Z]+(=|-))//g;
			foreach(split(/\s|�@/,$in{'cfillter_id'})){
				($_) = Mebius::Text::Alfabet("All-to-half",$_);
				$_ =~ s/��//g;
				$_ =~ s/^([A-Za-z0-9]+(=|-))//g;	# ���͓��e���� SOFTBANK= �ȂǁA�[���L�����폜
				$_ =~ s/((_|=|-)[A-Za-z0-9\.\/]+$)//g;	# ���͓��e���� �I���L�����폜
					if($_ =~ /([^\w\/\-\.])/){ main::error("ID�t�B���^ ( $_ ) �̒��Ɏg���Ȃ����� ( $1 ) ���܂܂�Ă��܂��B"); }
					if($_ eq $encid || $encid =~ /^${_}_/){ main::error("�������g ( $_ ) �̓t�B���^�ݒ�ł��܂���B"); }
				$i++;
				$set_cookie{'id_fillter'} .= qq($_ );
			}
		if($i > $max_fillter){ main::error("�h�c�t�B���^�́A�ő�$max_fillter�܂łł��B�V�����ǉ�����ɂ́A���̃t�B���^���폜���Ă��������B"); }
		$set_cookie{'id_fillter'} =~ s/\s+$//g;
		if(length $set_cookie{'id_fillter'}> $max_fillter*15){ main::error("�h�c�t�B���^���������܂��B"); }
	}

	# �A�J�E���g�t�B���^
	if(exists $in{'cfillter_account'}){
		my($i,$max_fillter) = (0,5);
			foreach(split(/\s|�@/,$in{'cfillter_account'})){
				($_) = Mebius::Text::Alfabet("All-to-half",$_);
				$_ = lc $_;
					if($_ =~ /([^a-z0-9])/){ main::error("�A�J�E���g�t�B���^ ( $_ ) �̒��ɁA�g���Ȃ����� ( $1 ) ���܂܂�Ă��܂��B"); }
					if($_ eq $main::pmfile){ main::error("�������g ( $_ ) �̓t�B���^�ݒ�ł��܂���B"); }
				$i++;
				$set_cookie{'account_fillter'} .= qq($_ );
			}
		if($i > $max_fillter){ main::error("�A�J�E���g�t�B���^�́A�ő�$max_fillter�܂łł��B�V�����ǉ�����ɂ́A���̃t�B���^���폜���Ă��������B"); }
		$set_cookie{'account_fillter'} =~ s/\s+$//g;
		if(length $set_cookie{'account_fillter'} > $max_fillter*10){ main::error("�A�J�E���g�t�B���^���������܂��B"); }
	}

	# �L�^�p
	#if($cfillter_account || $cfillter_id){ main::access_log("Fillter-mypage","�h�c�t�B���^�F$cfillter_id / �A�J�E���g�t�B���^�F $cfillter_account "); }

	# ���e�������I�t��
	if($in{'record_crireki'} eq "off"){
		$set_cookie{'use_history'} = "off";
	}

	# ���e���������Z�b�g
	elsif($in{'record_crireki'} eq "reset"){
		$set_cookie{'use_history'} = "off";
		require "${int_dir}part_history.pl";
		&get_reshistory("ACCOUNT UNLINK RENEW File-check-return My-file");
		&get_reshistory("CNUMBER UNLINK RENEW File-check-return My-file");
		&get_reshistory("KACCESS_ONE UNLINK RENEW File-check-return My-file");
		&get_reshistory("HOST UNLINK RENEW File-check-return My-file");
	}

	# ���e�������ĊJ
	elsif($in{'record_crireki'} eq "start" && $my_cookie->{'use_history'} eq "off"){ $set_cookie{'use_history'} = ""; }

	if($in{'cfollow'} eq "off"){ $set_cookie{'follow'} = "off";  }
	if($my_cookie->{'follow'} eq "off" && $in{'cfollow'} eq "on"){ $set_cookie{'follow'} = ""; }

	# �g���b�v����̏ꍇ
	if(exists $in{'ctrip'}){
			if($in{'ctrip'}){ $set_cookie{'name'} = "$in{'cnam'}#$in{'ctrip'}"; }
			else{ $set_cookie{'name'} = $in{'cnam'}; }
			if(length($in{'ctrip'}) > 20){ &my_error("�g���b�v���̕����񂪒������܂��B"); }
			if($in{'ctrip'} && length($in{'ctrip'}) <= 1){ &my_error("�g���b�v���̕����񂪒Z�����܂��B"); }
			if($in{'cnam'} eq $in{'ctrip'} && $in{'cnam'} && $in{'ctrip'}){ &my_error("�M���ƃg���b�v�̑f�͓����ɏo���܂���B"); }
	}

# �N�b�L�[�Z�b�g�����s
Mebius::Cookie::set_main(\%set_cookie,{ SaveToFile => 1 });

	# �����A�h�P�̃t�@�C�����X�V����ꍇ
	if(%renew_address){
		Mebius::Email::address_file("Renew-myaccess",$main::in{'cemail'},%renew_address);
	}

# �W�����v����`
	my($backurl_encode) = Mebius::Encode(undef,$in{'backurl'});
$jump_url = "$script?mode=settings&amp;backurl=$backurl_encoded";

	if($backurl && $in{'backurl_on'}){ $jump_url = $backurl; }
	if($in{'backurl'} eq ""){
		$jump_url = "$script?mode=settings&amp;backurl=$backurl_encoded";
	}

if($cermail_message){ $jump_sec = 60*60; }
else{ $jump_sec = 1; }

	# ���_�C���N�g����ꍇ
	if($main::in{'redirect'} && $backurl){
		Mebius::Redirect(undef,$backurl);
	}


# HTML
my $print = <<"EOM";
�}�C�y�[�W�̐ݒ��ύX���܂����B�i<a href="$jump_url">���߂�</a>�j<br$main::xclose>
$send_text1$return$after_text1
$cermail_message
EOM

Mebius::Template::gzip_and_print_all({},$print);

exit;

}



1;

