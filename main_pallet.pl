
use strict;
use Mebius::Paint;
package Mebius::Pallet;
use Mebius::BBS;

#-----------------------------------------------------------
# �����W���[���ʂ̐ݒ�
#-----------------------------------------------------------
sub Init{

my(%init);

# �X�L���̂���f�B���N�g��
if($main::admin_mode){ $init{'skin_directory'} = "/skin/"; }
else{ $init{'skin_directory'} = "../skin/"; }

if($main::server_domain =~ /^(aurasoul.mb2.jp|mb2.jp|localhost)$/){ $init{'paintmain_mode'} = 1; }

return(%init);

}

#-----------------------------------------------------------
# ���G�����p���b�g
#-----------------------------------------------------------
sub Start{

# �^�C�g����`
$main::sub_title = "���G�����p���b�g";
$main::head_link1 = qq( &gt; <a href="${main::main_url}newpaint-p-1.html">���G����</a> ); 
$main::head_link2 = qq( &gt; <a href="./?mode=pallet">�}�C�s�N�`��</a> ); 

# ���݂��}�C�i�X�̏ꍇ
if($main::cgold <= -1 && !$main::myadmin_flag && !$main::alocal_mode){ main::error("���݂��}�C�i�X�̂��߁A���G�����ł��܂���B","","","Not-repair"); }

# �Ǝ�Cookie���擾
our($cookie_concept,$cookie_session,$cookie_password) = undef;
my($cookie) = Mebius::get_cookie("Paint");
our($cookie_concept,$cookie_session,$cookie_password) = @$cookie;

# ���KURL
$main::canonical = "${main::main_url}pallet.html";

	# ���[�h�؂�ւ�
	if($main::submode2 eq "viewer" || $main::submode2 eq "animation"){ &Viewer(); }
	elsif($main::in{'type'} eq "edit"){ &Edit(); }
	elsif($main::in{'type'} eq "posted" || $main::in{'type'} eq "editor"){ &After_page(); }
	elsif($main::in{'type'} eq "pallet"){ &Pallet_page(); }
	elsif($main::in{'type'} eq "list_delete"){ &List_delete(); }
	elsif($main::in{'type'} eq "image_delete"){ &Image_delete(); }
	else{ &Before_page(); }

exit;

}

#-----------------------------------------------------------
# �G�̕ҏW
#-----------------------------------------------------------
sub Edit{

	# �ݒ�̎�荞��
	my(%init) = &Init();

	# �A�N�Z�X����
	main::axscheck();

	# �G���[�`�F�b�N
	if($main::in{'image_session'} eq ""){ main::error("���G����ID���w�肵�Ă��������B"); }
	if(length($main::in{'image_title'}) >= 20*2){ main::error("�G�̃^�C�g���͍ő�Q�O�����܂łł��B�i�S�p�j"); }
	if($main::in{'image_title'} =~ /^(\x81\x40|\s)+$/ || $main::in{'image_title'} eq ""){ main::error("�G�̃^�C�g������͂��Ă��������B"); }
	if(length($main::in{'comment'}) >= 2000*2){ main::error("�G�̐������͍ő�2000�����܂łł��B�i�S�p�j"); }

	# �{���̃`�F�b�N
	require "${main::int_dir}regist_allcheck.pl";
	($main::in{'comment'}) = main::all_check(undef,$main::in{'comment'},$main::in{'name'});
	if($main::e_com){ main::error("$main::e_com"); }

	# �ҏW�����s
	Mebius::Paint::Image("Edit-data Renew-logfile-buffer",$main::in{'image_session'});

	# ���̂܂܊G���m�肳����ꍇ
	if($main::in{'submit_type'} eq "soon" && $init{'paintmain_mode'}){

		my(%image) = Mebius::Paint::Image("Get-hash Post-check",$main::in{'image_session'});
		if($image{'post_ok'}){ }
		else{ main::error("�����̂��G�����摜�͊��ɓ��e�ς݁A�������͕ۑ��������؂�Ă��܂��B"); }

		# ���G�����摜���m�肳����
		my $resnumber_random = $main::time . int(rand(999));
		Mebius::Paint::Image("Rename-justy Renew-logfile-justy",$main::in{'image_session'},undef,$main::server_domain,"mpaint",$main::thisyear,$resnumber_random);
		Mebius::Paint::Image("Posted Renew-logfile-buffer",$main::in{'image_session'});

	}

	# �N�b�L�[���Z�b�g
	Mebius::Cookie::set_main({ name => $main::in{'name'} },{ SaveToFile => 1 });

	# ���e�m�肵���ꍇ�̃��_�C���N�g
	if($main::in{'submit_type'} eq "soon"){
		Mebius::Redirect("","${main::main_url}newpaint-p-1.html");
	}

	# �N�b�L�[������A���y�[�W�Ƀ��_�C���N�g����ꍇ
	elsif($main::in{'backurl'} && $main::backurl){
		Mebius::Redirect("",$main::backurl);
	}

	# ���̑��̏ꍇ�̃��_�C���N�g
	else{
		Mebius::Redirect("","${main::main_url}?mode=pallet");
	}

exit;

}


#-----------------------------------------------------------
# ���G������̃y�[�W
#-----------------------------------------------------------
sub After_page{

# �錾
my($line,$input_image_title,$input_comment);
my($not_form_flag);

# �ݒ�̎�荞��
my(%init) = &Init();

# CSS���`
$main::css_text .= qq(
textarea{width:400px;height:100px;}
td{vertical-align:top;}
div.post_guide{padding:1em;background:#fee;font-size:90%;margin:1em 0em;}
);

# �^�C�g����`
$main::head_link3 = qq(&gt; ���G��������);

# ���G����ID���N�b�L�[�ɃZ�b�g
Mebius::Paint::Image("Set-cookie-session Get-cookie",$main::in{'image_session'});

		#Mebius::Redirect("","${main::main_url}?mode=pallet&posted=1&backurl=$main::backurl_enc");

# �摜�擾
my(%image) = Mebius::Paint::Image("Get-hash Post-check",$main::in{'image_session'});

	# ������
	if(time < $image{'lasttime'} + 3*60){
		$line .= qq(�G��<strong class="red">�ꎞ�ۑ�</strong>���܂����B�i�܂����e����Ă��܂���j);
		$line .= qq(<br$main::xclose><br$main::xclose>);
	}

# �摜��\��
$line .= qq(<img src="$image{'image_url_buffer'}"$main::xclose>);

# 2012/3/27 (��)
Mebius::AccessLog(undef,"Paint-buffer-data-saved","���G����ID : $main::in{'image_session'} / URL : $image{'image_url_buffer'}");

# �X�e�b�v����\��
#$line .= qq(<br$main::xclose><br$main::xclose>);
#$line .= qq(�X�e�b�v���F $image{'all_steps'});

		# �X�e�b�v��������Ȃ��ꍇ
		if($image{'must_steps'} - $image{'all_steps'} >= 1){
			$line .= qq(<br$main::xclose><br$main::xclose><span class="alert">�����̂܂܂ł͓��e�m��ł��܂���B);
			$line .= qq(�����������J��<a href="./?mode=pallet#CONTINUE">��������`��������</a>���������B($image{'all_steps'} �X�e�b�v / $image{'must_steps'} �X�e�b�v )</span>);
			$not_form_flag = 1;
		}
		
# �y�C���g���Ԃ�\��
#$line .= qq(<br$main::xclose>);
#$line .= qq(�y�C���g���ԁF $image{'all_painttime'}�b);

		# �y�C���g���Ԃ�����Ȃ��ꍇ
		if($image{'must_painttime'} - $image{'all_painttime'} >= 1){
			$line .= qq(<br$main::xclose><br$main::xclose><span class="alert">�����̂܂܂ł͓��e�m��ł��܂���B);
			$line .= qq(�����������J��<a href="./?mode=pallet#CONTINUE">��������`��������</a>���������B�i $image{'all_painttime'}�a / $image{'must_painttime'}�b �j</span>);
			$not_form_flag = 1;
		}

# �������͓��e���`
$input_image_title = $image{'title'};
$input_comment = $image{'comment'};
$input_comment =~ s/<br>/\n/g;

	# �t�H�[��
	if(!$not_form_flag || $main::alocal_mode){

		#$line .= qq(<h2>�^�C�g���t��</h2>);

		# ����
		$line .= qq(<div class="post_guide">�G�Ƀ^�C�g����t����ƁA);
			if($main::in{'backurl'}){ $line .= qq(<a href="$main::backurl_href">�f���̃t�H�[��</a>); }
			else{ $line .= qq(�f���̃t�H�[��); }
		$line .= qq(�œY�t�������G��I�ׂ�悤�ɂȂ�܂��B);
		$line .= qq(���̂܂�<a href="./?mode=pallet#CONTINUE">��������`��</a>���Ƃ��o���܂��B</div>);

		$line .= qq(<form action="./" method="post">
		<div>

		<input type="hidden" name="mode" value="pallet"$main::xclose>
		<input type="hidden" name="type" value="edit"$main::xclose>
		<input type="hidden" name="image_session" value="$main::in{'image_session'}"$main::xclose>);

		# �߂��
		if($main::in{'backurl'}){ $line .= qq($main::backurl_input\n); }

		$line .= qq(<table>

		<tr>
		<td><label for="image_title">�G�̃^�C�g��</label></td>
		<td><span class="alert">���K�{</span></td>
		<td><input type="" name="image_title" value="$input_image_title" id="image_title"$main::xclose></td>
		</tr>

		<tr>
		<td><label for="name">�M��</label></td>
		<td><span class="alert">���K�{</span></td>
		<td><input type="text" name="name" value="$main::cnam" id="name"$main::xclose></td>
		</tr>

		<tr>
		<td><label for="comment">�G�̐���</label></td>
		<td><span class="guide">���ȗ���</span></td>
		<td><textarea name="comment" id="comment">$input_comment</textarea></td>
		</tr>

		<tr>
		<td></td>
		<td></td>
		<td>
		<input type="submit" name="action" value="���̓��e�ő��M����" class="isubmit"$main::xclose>);

		# ���̂܂܊m��`�F�b�N
			if($init{'paintmain_mode'} && ($image{'post_ok'} || $main::alocal_mode)){
				#$line .= qq(<br$main::xclose>\n);
				$line .= qq( <input type="radio" name="submit_type" value="save" id="submit_save"$main::parts{'checked'}$main::xclose>);
				$line .= qq( <label for="submit_save">�f���p�ɕۑ�</label>\n);
				$line .= qq(<input type="radio" name="submit_type" value="soon" class="isubmit" id="submit_soon"$main::xclose>);
				$line .= qq( <label for="submit_soon">���̂܂܊G���m��</label>\n);
				$line .= qq( ( <span class="guide">��<a href="${main::main_url}newpaint-p-1.html" class="blank" target="_blank">�V���ꗗ</a>�ɂ̂ݕ\\������܂� )</span>);
			}

		$line .= qq(
		</td>
		</tr>

		</table>
		</div>
		</form>
		);

	}



# HTML
my $print = $line;

Mebius::Template::gzip_and_print_all({},$print);


exit;

}

#-----------------------------------------------------------
# �m�F�y�[�W
#-----------------------------------------------------------
sub Before_page{

# �錾
my($line,$plus_pallet_checked,$animation_checked,$animation_checked,$continue_checked_flag,$continue_checked,$newpost_checked);
my($submit_button,$method,$applet_pro_checked,$applet_normal_checked,$agree_checked1,$agree_checked2);
our($cookie_concept,$cookie_session);

# �^�C�g����`
$main::head_link2 = qq(&gt; �}�C�s�N�`��);

# ���M�{�^��
$submit_button = qq(<input type="submit"  value="���G��������" class="paint_next">);

# CSS��`
$main::css_text .= qq(
.paint_next{font-size:120%;border:solid 1px #000;background:#fff;}
strong.alert{font-size:120%;}
);

# �t�H�[���J�n
if($main::myadmin_flag){ $method = "get"; }
else{ $method ="post"; }
$line .= qq(<form action="./?mode=pallet" method="$method"$main::sikibetu>);
$line .= qq(<div>);

# �\������
$line .= qq(<h1>���G��������</h1>);
$line .= qq(<span class="guide">�����ŕ`�����G�́A�f���ւ̓��e���Ɏg���܂��B�ڂ�����<a href="${main::guide_url}%A4%AA%B3%A8%A4%AB%A4%AD%B5%A1%C7%BD">���G�����K�C�h</a>���������������B�i<a href="http://aurasoul.mb2.jp/_qst/2556.html">������/�A���L��</a>�j</span>);


# ���p�K��ɓ���
if($cookie_concept =~ /Agree-alert/){ $agree_checked1 = $main::parts{'checked'}; }
$line .= qq(<br$main::xclose><br$main::xclose><input type="checkbox" name="agree1" value="on" id="agree1"$agree_checked1> <label for="agree1"><span class="alert">���́u�G������G�v�u�����݂̂̊G�v�u���I/�V���b�L���O�ȊG�v�u�L���Ɋ֌W�̂Ȃ��G�v�ȂǃT�C�g���[���ɔ�������͓̂��e���܂���B</span></label>\n);

# ���p�K��ɓ���
if($cookie_concept =~ /Agree-alert/){ $agree_checked2 = $main::parts{'checked'}; }
$line .= qq(<br$main::xclose><br$main::xclose><input type="checkbox" name="agree2" value="on" id="agree2"$agree_checked2> <label for="agree2"><span class="alert">���� <strong class="alert">�����Q�[��/�A�j�����̃L�����N�^�[</strong> �͕`���܂���B���쌠/�ё�������ė��p���܂��B(���쌠�t���[�̂��̂��̂���)</span></label><br$main::xclose>\n);

# �G�̖��O
$line .= qq(<br$main::xclose> $submit_button <br$main::xclose>\n);

# �I�v�V�����̑I��
$line .= qq(<h2>�I�v�V����</h2> );

$line .= qq(<input type="hidden" name="mode" value="pallet">\n);
$line .= qq(<input type="hidden" name="type" value="pallet">\n);
#$line .= qq(<input type="hidden" name="moto" value="$main::in{'moto'}">\n);
#$line .= qq(<input type="hidden" name="no" value="$main::in{'no'}">\n);


# �g���p���b�g�̑I��
if($cookie_concept =~ /Plus-pallet-on/){ $plus_pallet_checked = $main::parts{'checked'}; }
$line .= qq(<input type="checkbox" name="plus_pallet" value="on" id="plus_pallet"$plus_pallet_checked> <label for="plus_pallet">�g���p���b�g���g��</label><br$main::xclose>\n);

# �A�j���[�V�����̑I��
if($cookie_concept =~ /Animation-on/ || $cookie_concept eq ""){ $animation_checked = $main::parts{'checked'}; }
$line .= qq(<input type="checkbox" name="animation" value="on" id="animation"$animation_checked> <label for="animation">�A�j���[�V�������L�^����</label><br$main::xclose>\n);



# �����ւ��֎~
$line .= qq(<input type="checkbox" name="deny_sasikae" value="1" id="deny_sasikae"> <label for="deny_sasikae">����̍����ւ����֎~����</label><br$main::xclose>);

# �L�����o�X�̃T�C�Y
$line .= qq(<br$main::xclose>�L�����o�X�̃T�C�Y�F );
	my(@canvas_size) = Mebius::Paint::Canvas_size();
	foreach(@canvas_size){
		my $checked = $main::parts{'checked'} if($_ == 300);
		$line .= qq(<input type="radio" name="canvas_size" value="${_}x${_}" id="canvas_size${_}x${_}"$checked>);
		$line .= qq(<label for="canvas_size${_}x${_}">${_}x${_}</label>\n);
	}

# �A�v���b�g�̑I��
	if($cookie_concept =~ /Painter-pro/){ $applet_pro_checked = $main::parts{'checked'}; }
	else{ $applet_normal_checked = $main::parts{'checked'}; }
$line .= qq(<br$main::xclose><br$main::xclose>�A�v���b�g�F );
$line .= qq(<input type="radio" name="applet" value="" id="applet-normal"$applet_normal_checked> <label for="applet-normal">�����y�C���^�[</label>\n);
$line .= qq(<input type="radio" name="applet" value="pro" id="applet-pro"$applet_pro_checked> <label for="applet-pro">�����y�C���^�[�v��</label>\n);


$line .= qq(<br$main::xclose>);

# ���e�{�^��
#$line .= qq(<br$main::xclose><br$main::xclose>$submit_button);

	# ���u��������`���v��\��
	$line .= qq(<h2 id="CONTINUE">��������`���ꍇ</h2> );

	$line .= qq(�o���オ�����G�́c );
	$line .= qq(<input type="radio" name="continue_type" value="sasikae" id="sasikae"$main::parts{'checked'}> <label for="sasikae">�ȑO�̊G�ƍ����ւ���</label>);
	$line .= qq(<input type="radio" name="continue_type" value="new" id="sinnki"> <label for="sinnki">�V�K�G�����ɂ���</label><br$main::xclose><br$main::xclose>);


	# �V�����`��
	if(!$main::in{'continue'}){ $newpost_checked = $main::parts{'checked'}; }
	$line .= qq(<input type="radio" name="continue_session" value="" id="not_continue"$newpost_checked> <label for="not_continue">���I��</label><br$main::xclose>);

	# �N�b�L�[�̔z���W�J
	foreach(split(/\s/,$cookie_session)){

		# �����̂��G����ID�i�Z�b�V�������j���炻�ꂼ��A�摜URL���̃f�[�^���擾
		my(%image) = Mebius::Paint::Image("Get-hash Post-check",$_);

			# �ꎞ�摜�����݂���ꍇ
			if($image{'continue_ok'}){

					# ��ԐV�����摜�ɏ����`�F�b�N������
					if(!$continue_checked_flag && $main::in{'continue'}){
						$continue_checked = $main::parts{'checked'};
						$continue_checked_flag = 1;
					}

				# ���W�I�{�b�N�X�A�o�b�t�@�摜�̃T���l�C����\��
				$line .= qq(<br$main::xclose><hr><br$main::xclose><input type="radio" name="continue_session" value="$image{'session'}" id="session-$image{'session'}"$continue_checked>);
				$line .= qq(<label for="session-$image{'session'}"> ���G����ID�F $image{'session'} �̑�������`���B</label>\n);
				$line .= qq(<br$main::xclose>);
				$line .= qq(<a href="$image{'image_url_buffer'}" target="_blank" class="blank"><img src="$image{'samnale_url_buffer'}" alt="�`�������̉摜" class="noborder"></a>\n);
						if($image{'deny_sasikae'}){ $line .= qq( <span class="red">(�����ւ��֎~)</span>); }
						if($image{'image_posted'}){ $line .= qq( <span class="blue">(���e�ς�)</span>); }
				$line .= qq( <span class="guide">�ۑ����� �F ����$image{'lefthour'}����</span>);
				$line .= qq(�@<a href="./?mode=pallet&amp;type=list_delete&amp;image_session=$image{'session'}">�ꗗ����폜</a>);
					if(!$image{'image_posted'}){ $line .= qq(�@<a href="./?mode=pallet&amp;type=editor&amp;image_session=$image{'session'}">���^�C�g���t��</a>); }
				$line .= qq(<br$main::xclose>);
			}
			
			# �ۑ������̒��߂ȂǁA��������`���Ȃ��ꍇ
			#elsif($main::myadmin_flag >= 5){
			#	$line .= qq(�E���G����ID�F $image{'session'} �͕ۑ��������߂��Ă��܂��B\n);
			#	$line .= qq(<br$main::xclose>\n);
			#}
	}

	# ��ł��̓��̓{�b�N�X
	$line .= qq(<input type="radio" name="continue_session" value="select_by_text"> );
	$line .= qq(���G����ID�F<input type="text" name="continue_session_text" value=""> �̑�������`���B�i���p�p��������ł��œ��͂��Ă��������j<br$main::xclose>);

	# �߂��URL
	if($main::in{'backurl'}){ $line .= qq($main::backurl_input); }

# �p�X���[�h�̓���
#$line .= qq(<input type="password" name="password" value="$cookie_password">);

$line .= qq(<br$main::xclose><br$main::xclose>$submit_button\n);

$line .= qq(</div>);
$line .= qq(</form>);


Mebius::Template::gzip_and_print_all({},$line);

}

#-----------------------------------------------------------
# �p���b�g�y�[�W�S��
#-----------------------------------------------------------
sub Pallet_page{

# �錾
my($pallet_line,$set_cookie_concept);
our($cookie_session,$cookie_password);

# �^�C�g����`
$main::head_link4 = qq(&gt; �p���b�g);

# �A�N�Z�X����
main::axscheck("");

# ���C��SS���`
push(@main::css_files,"pallet");

	# ���Ǝ�Cookie���Z�b�g
	# ��ꂽ Cookie��؂��� 2012/3/25 (��)
	if(length $cookie_session >= 1000){ $cookie_session = substr $cookie_session , 0 , 100; }
	if($main::in{'animation'} eq "on"){ $set_cookie_concept .= qq( Animation-on); }
	if($main::in{'plus_pallet'} eq "on"){ $set_cookie_concept .= qq( Plus-pallet-on); }
	if($main::in{'applet'} eq "pro"){ $set_cookie_concept .= qq( Painter-pro); }
	if($main::in{'agree1'} eq "on" && $main::in{'agree2'}){ $set_cookie_concept .= qq( Agree-alert); }

Mebius::set_cookie("Paint",[$set_cookie_concept,$cookie_session,$cookie_password]);

# �p���b�g���擾
($pallet_line) = Mebius::Pallet::Pallet();

# Javascript���擾
Mebius::Pallet::Head_javascript();

Mebius::Template::gzip_and_print_all({},$pallet_line);

}

#-----------------------------------------------------------
# ���G�����p���b�g
#-----------------------------------------------------------
sub Pallet{

# �錾
my($security_timer,$applet,$plus_pallet1,$plus_pallet2);

# �A�v���b�g���擾
($applet) = &Applet();

	# �g���p���b�g���擾
	if($main::in{'plus_pallet'} eq "on"){
		($plus_pallet1) = &Plus_pallet1();
		($plus_pallet2) = &Plus_pallet2();
	}

# �{�f�B�[
my $line = qq(
<div align="center"> 

<span class="alert">�����f�s�ׂ��������ꍇ�A���� <strong>���e����</strong> �����Ē����ꍇ������܂��B</span><br$main::xclose>);

# �g�����K�C�h
$line .= qq(<span class="guide">�K�C�h�F );

	#if($main::in{'applet'} eq "pro"){
	#	$line .= qq(<a href="http://piclab.sakura.ne.jp/kouza2/kihonP/menu.htm" target="_blank" class="blank">�����y�C���^�[�v���̎g����</a> (�O���T�C�g));
	#}
	#else{
	#	$line .= qq(<a href="http://piclab.sakura.ne.jp/kouza2/kihonH/menu.htm" target="_blank" class="blank">�����y�C���^�[�̎g����</a> (�O���T�C�g));
	#}

	$line .= qq(<a href="http://oekakiart.net/kouza/020shipainter/" target="_blank" class="blank">�����y�C���^�[�̎g����</a> (�O���T�C�g));

# JAVA�C���X�g�[��
$line .= qq( / ���삵�Ȃ��ꍇ�� <a href="http://www.java.com/ja/" class="blank" target="_blank">JAVA���C���X�g�[��</a> ���Ă��������B );


$line .= qq(</span><br$main::xclose><br$main::xclose>);

$line .= qq(
<table><tr> 
<td align="right valign-top"> 
$plus_pallet1
</td> 
<td class=" align-top" style="padding:0em 1em;">
$applet

</td> 
<td class="valign-top"> 
$plus_pallet2

</td></tr></table> 


</div> 

);
 
# ���쌠�\��
$line .= qq(
<br> 
<div align=right class="nextback">
<a href="http://hp.vector.co.jp/authors/VA016309/spainter/" title="������" target="_blank" class="blank"> 
+Paint-Applet &copy; Shi-dow</a>
</div>

);

return($line);


#-----------------------------------------------------------
# ���G�����A�v���b�g����
#-----------------------------------------------------------
sub Applet{

# �錾
my(%init) = &Init();
my($line,$image_session,$animation_flag);
my(%image,$sasikae_flag,$continue_flag,$continue_flag,$continue_session,$url_save,$continue_type);
my($image_title,$applet_width,$applet_height,$backurl_pallet,$super_id,$applet_url);
my($image_size,$compress_level,$image_width,$image_height,$deny_sasikae_flag,$image_title_enc,$url_exit);

# CSS��`
$main::css_text .= qq(
div.valaety_data{line-height:1.4em;margin:1em auto;width:80%;}
);

	# �K��ւ̓��ӂ��`�F�b�N
	if($main::in{'agree1'} eq "on" && $main::in{'agree2'} eq "on"){ }
	else{ main::error("�K��ւ̓��ӂ��Ȃ��ƁA���G�����o���܂���B"); }

# �摜�Z�b�V����ID
($image_session) = Mebius::Crypt::char("",12);

	# ��������`���ꍇ�A�e��f�[�^���擾

	# �e�L�X�g�Ŏ�ł������ꍇ
	if($main::in{'continue_session'} eq "select_by_text"){
		$continue_session = $main::in{'continue_session_text'};
	}
	# ���W�I�{�b�N�X���w�肵���ꍇ
	elsif($main::in{'continue_session'}){
		$continue_session = $main::in{'continue_session'};
	}
	# �R���e�B�j���[�̂��߂Ƀo�b�t�@�E���O�f�[�^���`�F�b�N 
	if($continue_session){
		(%image) = Mebius::Paint::Image("Get-hash Get-cookie",$continue_session);
			if(-e $image{'animation_file_buffer'}){	$continue_flag = 1; }
	}

# �t�H�[�����J���Ă���`�b�ȓ��̑��M���֎~
#$security_timer = 180;
#if($main::alocal_mode || $main::myadmin_flag){ $security_timer = 0; }

	# ����
	my($canvas_select_width,$canvas_select_height) = split(/x/,$main::in{'canvas_size'});

	# �L�����o�X�̉���
	$image_width = 300;
	if($image{'width'}){ $image_width = $image{'width'}; }								# �R���e�B�j���[
	elsif($main::in{'image_width'}){ $image_width = $main::in{'image_width'}; }			# ��ł��Ŏw��
	elsif($canvas_select_width){ $image_width = $canvas_select_width; }					# �e���v������w��

	# �L�����o�X�̏c��
	$image_height = 300;
	if($image{'height'}){ $image_height = $image{'height'}; }							# �R���e�B�j���[
	elsif($main::in{'image_height'}){ $image_height = $main::in{'image_height'}; }		# ��ł��Ŏw��
	elsif($canvas_select_height){ $image_height = $canvas_select_height; }				# �e���v������w��

	# �L�����o�X�T�C�Y�̈ᔽ�`�F�b�N
	my($error_flag_canvassize) = Mebius::Paint::Canvas_size("Violation-check",$image_width,$image_height);
	if($error_flag_canvassize){ main::error("$error_flag_canvassize"); }

	# �A�v���b�g�{�̂̕\���T�C�Y
	$applet_width = 490;
	$applet_height = 450;
	if($image_width >= 400){ $applet_width = $image_width + 90 + 50; }
	if($image_height >= 400){ $applet_height = $image_height + 50 + 50; }
	if($main::in{'applet'} eq "pro"){ $applet_width += 100; }
	if($main::in{'applet'} eq "pro"){ $applet_height += 100; }

	# �����ւ��֎~
	if($main::in{'deny_sasikae'}){ $deny_sasikae_flag = 1; }

	# �A�j���[�V�����̋L�^�I��/�I�t
	if($main::in{'animation'} eq "on"){ $animation_flag = 1; }

	# ���e�p�X�N���v�g
	if($main::alocal_mode){ $url_save = "/cgi-bin/getpics.cgi"; }
	else{ $url_save = "/main/getpics.cgi"; }

	# �u��������`���v���u�V�K�G�����v���̃X�[�p�[ID
	if($continue_flag && $main::in{'continue_type'} eq "new"){ $super_id = $image{'super_id'}; }

	# �G�ɂ��閼�O
	if($main::in{'image_title'}){
		($image_title_enc) = Mebius::Encode("",$main::in{'image_title'});
		$image_title = $main::in{'image_title'};
	}
	elsif($continue_flag){
		$image_title = $image{'title'};
		($image_title_enc) = Mebius::Encode("",$image{'title'});
	}

# �A�v���b�g�̑I��
if($main::in{'applet'} eq "pro"){ $applet_url = "$init{'skin_directory'}spainter.jar,$init{'skin_directory'}pro.zip"; }
else{ $applet_url = "$init{'skin_directory'}spainter.jar,$init{'skin_directory'}normal.zip"; }


# �A�v���b�g�J�n
$line .= qq(
<!--����������A�v���b�g--> 
<applet mayscript code="c.ShiPainter.class" archive="$applet_url" name="paintbbs" style="width:${applet_width}px;height:${applet_height}px;"> 
<param name="header_magic" value="S"> 
<param name="url_save" value="$url_save">\n);

	# �����f�[�^����͂����ꍇ
	if($continue_flag){

			# ��������`������ǁA�V�K���e�ɂ���ꍇ
			if($main::in{'continue_type'} eq "new"){
				$continue_type = "new";
			}

			# ��������`���A�����ւ�����ꍇ�i���G����ID���ꏏ�Ɂj
			elsif($main::in{'continue_type'} eq "sasikae"){
					if($image{'deny_sasikae'}){ main::error("���̊G�͍����ւ��֎~�ł��B�V�K���e��I��ł��������B"); }
				$continue_type = "sasikae";
				$image_session = $image{'session'};
				$sasikae_flag = 1;
			}
			else{ main::error("�����ւ����V�K���e��I��ł��������B"); }

		$line .= qq(<param name="pch_file" value="$image{'animation_url_buffer'}">\n);
	}

	# ���e��Ɉړ�����URL
	if($main::in{'backurl'}){ $backurl_pallet = $main::backurl_enc; }
	$url_exit = "${main::main_url}?mode=pallet&amp;type=posted&amp;image_session=$image_session&amp;backurl=$backurl_pallet";
	$line .= qq(<param name="url_exit" value="$url_exit">\n);


	# ���k���x��
	if($image{'compress_level'}){
		$compress_level = $image{'compress_level'};
	}
	elsif($main::in{'plus_pallet'} eq "on"){
		$compress_level = 7;	# �l�������������h���h�掿
		$image_size = 100;
	}
	else{
		$compress_level = 15;	# �l���傫�������h��h�掿
		$image_size = 60;
	}


	# �g���w�b�_
	$line .= qq(<param name="send_header" value=");
	$line .= qq(image_session=$image_session&super_id=$super_id&pass=&name=&applet=shipainter&width=$image_width&height=$image_height);
	$line .= qq(&anime=1&pchsave=1&painttime=&paintstarttime=$main::time&ptimeoff=&quality=1&animation_on=$animation_flag&sasikae=$sasikae_flag);
	$line .= qq(&deny_sasikae=$deny_sasikae_flag&continue_type=$continue_type&image_title=$image_title_enc);
	$line .= qq(&samnale_width=120&samnale_height=120&compress_level=$compress_level);
	$line .= qq(&">);

	$line .= qq(
	<param name="animation_max" value="0"> 
	<param name="compress_level" value="$compress_level"> 
	<param name="dir_resource" value="$init{'skin_directory'}">);

$line .= qq(<param name="image_height" value="$image_height"> 
<param name="image_interlace" value="false">
<param name="image_jpeg" value="true">
<param name="image_size" value="$image_size">
<param name="image_width" value="$image_width">
<param name="layer_count" value="3">
<param name="poo" value="false">
<param name="quality" value="1">\n);

# ���G��������
if($main::in{'applet'} eq "pro"){ $line .= qq(<param name="res.zip" value="$init{'skin_directory'}res_pro.zip">\n); }
else{ $line .= qq(<param name="res.zip" value="$init{'skin_directory'}res_normal.zip">\n); }

$line .= qq(<param name="tt.zip" value="$init{'skin_directory'}tt.zip">\n);

$line .= qq(
<param name="security_click" value="0"> 
<param name="security_post" value="0">\n);

# Java �ɂ��b������
#$line .= qq(<param name="security_timer" value="$security_timer">);
#$line .= qq(<param name="security_url" value="${main::guide_url}%A4%AA%B3%A8%A4%AB%A4%AD%BB%FE%B4%D6%A5%A8%A5%E9%A1%BC">);

$line .= qq(<param name="send_advance" value="true">
<param name="send_header_count" value="true">
<param name="send_header_image_type" value="true">
<param name="send_header_timer" value="true">
<param name="send_language" value="sjis">
<param name="thumbnail_compress_level" value="15">
<param name="thumbnail_width" value="120">
<param name="thumbnail_height" value="120">\n);

# �A�j���I��/�I�t
$line .= qq(<param name="thumbnail_type" value="animation">\n);
$line .= qq(<param name="thumbnail_type2" value="jpeg">\n);

# �g�p�c�[��
if($main::in{'applet'} eq "pro"){ $line .= qq(<param name="tools" value="pro">\n); }
else{ $line .= qq(<param name="tools" value="normal">\n); }


$line .= qq(<param name="undo" value="100">
<param name="undo_in_mg" value="50"> 

<!--�A�v���b�g--> 
<param name="image_bkcolor" value="">	<!--�L�����o�X�̔w�i�F--> 
<param name="image_bk" value="">	<!--�A�v���b�g�̔w�i�̃C���[�W(�^�C������\��)--> 
<param name="color_text" value="#8099b3">	<!--�A�v���b�g�̃e�L�X�g�J���[--> 
<param name="color_bk" value="#ffffff">	<!--�A�v���b�g�̔w�i�J���[--> 
<param name="color_bk2" value="#ccddee">	<!--�A�v���b�g�̖ԏ�̐��̃J���[--> 
<!--�A�C�R��--> 
<param name="color_icon" value="#eef3f9">	<!--�A�C�R���̃J���[--> 
<param name="color_frame" value="#ccddee">	<!--�A�C�R���̘g�̃J���[--> 
<param name="color_iconselect" value="#ffccb3">	<!--�A�C�R����I�����o��g�̃J���[--> 
<!--�X�N���[���o�[--> 
<param name="color_bar" value="#ccddee">	<!--�o�[�̃J���[--> 
<param name="color_bar_hl" value="#aaccee">	<!--�o�[�̃n�C���C�g�J���[ --> 
<param name="color_bar_frame_hl" value="#ffffff">	<!--�o�[�̃t���[���̃n�C���C�g--> 
<param name="bar_size" value="20">	<!--�o�[�̑���--> 
<!--�c�[���o�[--> 
<param name="tool_color_button" value="#fffafa">	<!--�{�^���̐F��--> 
<param name="tool_color_button2" value="#fffafa">	<!--�{�^���̐F��--> 
<param name="tool_color_text" value="#806650">	<!--�e�L�X�g�̐F--> 
<param name="tool_color_bar" value="#fffafa">	<!--�ύX�o�[�̐F--> 
<param name="tool_color_frame" value="#808080">	<!--�g�̐F--> 
</applet> 
<!--�������܂ŃA�v���b�g--> 
);

# �e��f�[�^
$line .= qq(<div class="valaety_data">\n);

$line .= qq(<br$main::xclose>�� ���G����ID�F <span class="red">$image_session</span> �i�����K�{�j);
	if($image_title){ $line .= qq(<br$main::xclose>�� �^�C�g���F $image_title); }
	if($deny_sasikae_flag){ $line .= qq(<br$main::xclose>�� ����̍����ւ����֎~���܂�); }
	if($animation_flag){ $line .= qq(<br$main::xclose>�� �A�j���[�V�������L�^���܂�); }
	if($continue_type eq "sasikae"){ $line .= qq(<br$main::xclose>�� <a href="$image{'image_url_buffer'}" target="_blank" class="blank">$image{'session'}</a> �̑�������`���A�����ւ��܂�); }
	elsif($continue_type eq "new"){ $line .= qq(<br$main::xclose>�� <a href="$image{'image_url_buffer'}" target="_blank" class="blank">$image{'session'}</a> �̑�������`���A�V�K���e���܂�); }
$line .= qq(<br$main::xclose>�� �L�����o�X�T�C�Y�F ��${image_width} x �c${image_height}\n);
if($main::myadmin_flag >= 5){ $line .= qq(<br$main::xclose>�� �X�[�p�[ID�F $image{'super_id'}); }
$line .= qq(<br$main::xclose>���G���o�����獶��́u���e�v�������Ă��������B);

$line .= qq(</div>);

return($line);

}


#-----------------------------------------------------------
# �摜�̍폜�i�Ǘ��p�j
#-----------------------------------------------------------
sub Image_delete{

my($type) = @_;

	# �����G���[
	if(!$main::admin_mode){ main::error("�폜�ł���̂͊Ǘ��҂݂̂ł��B"); }

	# �摜�f�[�^���擾
	my(%image) = Mebius::Paint::Image("Get-hash Justy",undef,undef,undef,$main::in{'realmoto'},$main::in{'postnumber'},$main::in{'resnumber'});

	# �摜���폜����
	if($main::in{'delete_type'} =~ /^(delete|penalty)$/){
		Mebius::Paint::Image("Delete-image Justy Renew-logfile-justy",undef,undef,undef,$main::in{'realmoto'},$main::in{'postnumber'},$main::in{'resnumber'});
	}

	# �摜�𕜊�����
	elsif($main::in{'delete_type'} eq "revive"){
		Mebius::Paint::Image("Revive-image Justy Renew-logfile-justy",undef,undef,undef,$main::in{'realmoto'},$main::in{'postnumber'},$main::in{'resnumber'});
	}

	# ���[�h�G���[
	else{
		main::error("���s�^�C�v���w�肵�Ă��������B");
	}

	# �y�i���e�B��^����
	if($main::in{'delete_type'} eq "penalty"){
		my $penalty_url = "/_$main::in{'realmoto'}/$main::in{'postnumber'}.html#S$main::in{'resnumber'}" if($image{'main_type'});
		if($image{'host'}){ Mebius::penalty_file("Host Penalty Renew",$image{'host'},$image{'title'},"�y�摜�̓��e�z",$penalty_url); }
		if($image{'cnumber'}){ Mebius::penalty_file("Cnumber Penalty Renew",$image{'cnumber'},$image{'title'},"�y�摜�̓��e�z",$penalty_url); }
		if($image{'account'}){ Mebius::penalty_file("Account Penalty Renew",$image{'account'},$image{'title'},"�y�摜�̓��e�z",$penalty_url); }
	}

	# �y�i���e�B����������
	if($main::in{'delete_type'} eq "revive"){
		if($image{'host'}){ Mebius::penalty_file("Host Repair Renew",$image{'host'}); }
		if($image{'cnumber'}){ Mebius::penalty_file("Cnumber Repair Renew",$image{'cnumber'}); }
		if($image{'account'}){ Mebius::penalty_file("Account Repair Renew",$image{'account'}); }
	}

	# ���_�C���N�g
	if($main::in{'backurl'} && $main::backurl && $main::in{'allow_backurl'}){
		Mebius::Redirect(undef,$main::backurl);
	}
	else{
Mebius::Redirect(undef,"${main::main_url}?mode=pallet-viewer-$main::in{'realmoto'}-$main::in{'postnumber'}-$main::in{'resnumber'}$main::backurl_query_enc");
	}

}


#-----------------------------------------------------------
# �G(Cookie)�̍폜
#-----------------------------------------------------------
sub List_delete{

# Cookie���폜
Mebius::Paint::Image("Get-cookie Delete-cookie-session",$main::in{'image_session'});

	# ���_�C���N�g
	if(!$main::in{'redirected'}){
		Mebius::Redirect("","${main::main_url}?redirected=1&$main::postbuf");
	}

# ���_�C���N�g�Ղ͕��ʂɊm�F�y�[�W��\��
&Before_page();

exit;

}

no strict;

#-----------------------------------------------------------
# �g���Ă��Ȃ��t�H�[��
#-----------------------------------------------------------

$form1 = qq(
<table class="qtable"><tr><td align="center" class="qtd"><p> 
<form name="paintform"> 
	<span title="�L�����o�X�̃T�C�Y�ƃN�I���e�B�l�A�A�v���b�g��ύX���܂��B

�ςɂȂ�ꍇ�́A�T�C�Y���̂܂܂ł�����x�ύX�{�^���������ƒ��邱�Ƃ������ł�"> 
	<small>Size</small> <input type="text" name="width" value="300" size=4>x<input type="text" name="height" value="300" size=4> 
	<small>Quality</small> 
<input type="hidden" name="quality" value=""> 
	<select name="kari"> 
		<option value="1">�����M���ĕ`�������
		<option value="2">�����M���ĉ摜������
		
	</select> 
	<select name="mode"> 
		<option value="paintbbs">PaintBBS</option> 
<option value="shipainter" selected>ShiPainter</option> 
<option value="shipainterpro">ShiPainter-Pro</option> 
 
	</select><br> 
	<input type="button" onClick="sizechange()" value="�T�C�Y�E�N�I���e�B�E�A�v���b�g�ύX"><br><br> 
	<small>�� ���u�摜�����Ɂv�̏ꍇ�̂݃T�C�Y���ς����܂��B(PNG�̏ꍇ�͊��Ɉˑ�)<br> 
	(�uPaintBBS�v�́u�`������Ɂv���T�C�Y�����ύX�ł��܂�)<br> 
	�� ���u�����y�C���^�[�v�Ԃ����`������ɃA�v���b�g�̕ύX���ł��܂��B<br> 
	
	�� �� �����ŁA���́u�摜�̕ۑ��t�H�[�}�b�g�v�̑I�����L���ɂȂ�܂��B<br> 
	</small> 
</form> 
</p></td></tr></table> 

 
);

$form2 = qq(
<table><tr><td align="center"> 
	<table class="qtable"><tr><td align="center" class="qtd"><p> 
	<form action="" method="post"> 
	<input type="hidden" name="no" value=""> 
	<input type="hidden" name="mode" value="shipainter"> 
	<input type="hidden" name="type" value=""> 
	<input type="hidden" name="pass" value=""> 
	<input type="hidden" name="width" value="300"> 
	<input type="hidden" name="height" value="300"> 
	<input type="hidden" name="quality" value=""> 
	<input type="hidden" name="anime" value="1"> 
	<input type="hidden" name="painttime" value="1278320484"> 
	<span title="�A���h�D�̉񐔂�ς��܂�.">�A���h�D
	<input type="text" name="undo" value="100" size="3">��
	<input type="text" name="undo_in_mg" value="50" size="2">�ɕ�����
	<input type="submit" value="�ύX"> 
	</span> 
	</form> 
	</p></td></tr></table> 

	<table class="qtable"><tr><td align="center" class="qtd"><p> 
	<form action="" method="post"> 
	<input type="hidden" name="no" value="$main::in{'no'}"> 
	<input type="hidden" name="moto" value="$main::in{'moto'}">
	<input type="hidden" name="mode" value="pallet"> 
	<input type="text" name="image_width" value="$image_width"> 
	<input type="text" name="image_height" value="$image_height"> 
	<input type="submit" value="�ύX"> 
	</span> 
	</form> 
	</p></td></tr></table> 

);

$form3 = qq(
<table><tr><td align="center"> 
<input type="button" onClick="botusend()" value=" �{ �c " title="�摜�����ꎞ�I�ɓ��e���A�ۑ����邱�Ƃ��ł��܂��B���O�ɂ͋L�^����܂���B"> 
 
</td></tr></table> 
);

}

#-----------------------------------------------------------
# �g���p���b�g�P
#-----------------------------------------------------------
sub Plus_pallet1{

# �錾
my($line);

$line .= qq(
	<table class="ptable"><tr><td align=right class="ptd"><p> 
	<form name="nowpform"> 
	<span id="nowpl" title="���̃J�[�\���̍��W. �����A�E�ɃZ�b�g�������_����̑��΍��W�B�E�����Z�b�g���Ă��錴�_�̐�΍��W. �L�����o�X�̍���̍��W��ł����ނƂ��������B(�蓮�G)">���W<br> 
	X<input type="text" name="nowpx" value="" size="3" title="���� X���W">+
	<input type="text" name="setpx" value="0" size="2" onblur="setposition()" title="���_(0,0)�ɂ��� X���W. �t�H�[�J�X�A�E�g�ŌŒ�"><br> 
	Y<input type="text" name="nowpy" value="" size="3" title="���� Y���W">+
	<input type="text" name="setpy" value="0" size="2" onblur="setposition()" title="���_(0,0)�ɂ��� Y���W. �t�H�[�J�X�A�E�g�ŌŒ�"><br> 
	</span> 
	</form> 
	</p></td></tr></table> 
 
<script language="javascript"><!--
	var d=document;
	if(d.layers){ d.captureEvents(Event.MOUSEMOVE); }
	d.onmousemove=nowposition;
//--></script> 
	<table class="ptable"><tr><td align=right class="ptd"> 
	<span title="�A�v���b�g�t�B�b�g�B

�A�v���b�g�̃T�C�Y����ʂ̃T�C�Y�ɍ��킹�܂�"> 
	App-Fit<br></span> 
	<input type="button" onClick="appletfit()" value="On"><br> 
	<input type="button" onClick="appletfit(1)" value="Off"></span><br> 
	</td></tr></table> 
	<table class="ptable"><tr><td align=right class="ptd"><p> 
	<form name="scalf"> 
	<span title="�g��E�k��"> 
	<sup>�g��/�k��</sup></span><br> 
	<input type="button" onClick="scale(1)" value="���{" title="1�{��"><br> 
	<input type="button" onClick="scale(2)" value="�Q�{" title="2�{��"><br> 
	<input type="button" onClick="scale(3)" value="�R�{" title="3�{��"><br> 
	<input type="button" onClick="scale(5)" value="�T�{" title="5�{��"><br> 
	<input type="button" name="scalx" onClick="scale(0,2)" value="*2" title="����2�{�Ɋg�� (�ő�128�{)"><br> 
	<input type="button" name="scaly" onClick="scale(0,0,2)" value="*0.5" title="����1/2�{�ɏk�� (�؂�グ)"><br> 
	</form> 
	</p></td></tr></table> 
	<table class="ptable"><tr><td align=right class="ptd"><p> 
	<form name="layerform"> 
	<span title="���C���[�̒ǉ��ƍ폜"> 
	���C���[</span><br> 
	<span title="��ԏ�Ƀ��C���[�ǉ�"> 
	<input type="button" onClick="layeradd()" value="�ǉ�"></span><br> 
	<span title="��ԏ�̃��C���[���폜�B���ɖ߂��Ȃ��̂Œ��ӁB"> 
	<input type="button" onClick="layerdel()" value="�폜"></span><br> 
	<span title="���C���[��I�����܂�">L-select<br> 
	<select name="layernum" size="4" onChange="layerselect(this.options[this.selectedIndex].value,this.options[this.selectedIndex].text)"> 
		<option value="2">layer2</option> 
		<option value="1">layer1</option> 
		<option value="0" selected>layer0</option> 
 
	</select><br> 
	</span> 
	<span title="���������ƁA�I�𒆂̃��C���[�̖��O��ύX�ł��܂�">���C���[��<br> 
	<input type="text" name="layername" value="layer0" size=9 onblur="lnamechange()"><br> 
	</span> 
	</form> 
	</p></td></tr></table> 
 );

return($line);

}

#-----------------------------------------------------------
# �g���p���b�g�Q
#-----------------------------------------------------------
sub Plus_pallet2{

# �錾
my($line);

$line .= qq(

 
	<nobr> 
	<input type="button" onclick="pentool(0,0,255,0,-8,true,false)" value="��"> 
	<input type="button" onclick="pentool(3,2,180,12,-5,false,false)" value="��"> 
	<input type="button" onclick="pentool(2,2,64,12,-8,true,false)" value="��"> 
	<input type="button" onclick="pentool(1,0,120,0,-8,false,true)" value="�y">&nbsp;
	<wbr> 
	<input type="button" onclick="hinttool(0)" value="��"> 
	<input type="button" onclick="hinttool(3)" value="��"></nobr><br> 
<script type="text/javascript"><!--
		palette_selfy();
	//--></script> 
</td> 
</tr></table> 
 
<table><tr><td align="center"> 
	<small>���g���c�[�����낢��. �{�^���I���}�E�X�ł��낢��������ł܂�. 
	<br><br></small> 
</td></tr></table> 
<table class="qtable"><tr><td align="center" class="qtd"><p> 
<form name="glidform"> 
	<span title="�c�[���B"> 
		<input type="hidden" name="toolg" value="0"> 
	</span> 
	<span title="���C���������Ԋu�B0�Ȃ�Ȃ��B">�Ԋu
		x<input type="text" name="widg" value="25" size="3"> 
		y<input type="text" name="heig" value="25" size="3"> 
	</span> 
	<span title="�O���b�h�̂Ƃ��͌X���A�W�����̂Ƃ��̒��S���W���B

���Ȃ݂ɃL�����o�X�̒��S��(x,y) = (0,0)�ł�">�X���E���S
		x<input type="text" name="cenx" value="0" size="3"> 
		y<input type="text" name="ceny" value="0" size="3"> 
	</span> 
	<span title="���C���������Ԋu�B0�Ȃ�Ȃ��B">����
		<select name="leng"> 
			<option value="100">100%</option> 
			<option value="90">90%</option> 
			<option value="80">80%</option> 
			<option value="70">70%</option> 
			<option value="60">60%</option> 
			<option value="50">50%</option> 
			<option value="40">40%</option> 
			<option value="30">30%</option> 
			<option value="20">20%</option> 
			<option value="10">10%</option> 
			<option value="0">0%</option> 
			<option value="110">110%</option> 
			<option value="125">125%</option> 
			<option value="150">150%</option> 
			<option value="175">175%</option> 
			<option value="200">200%</option> 
			<option value="225">225%</option> 
			<option value="250">250%</option> 
		</select><br> 
	</span> 
	�����_��
	<span title="�Ԋu�������_���ɂ���B"> 
		<input type="checkbox" name="randg" value="1" class="ra">�Ԋu
	</span> 
	<span title="�Ԋu�������_���ɂ���B"> 
		<input type="checkbox" name="randl" value="1" class="ra">����
	</span> 
	<span title="���̃��C���[�ɃO���b�h��W�������Ђ��܂��B

����F�A�����A�A���t�@�l�Ȃǂ̓p���b�g�̏�ԂŁB

�y���͍��̂Ƃ���ł��Ȃ������̂łł��܂���"> 
		<input type="button" value="�O���b�hON" onClick="glidres(0)"> 
		<input type="button" value="�W����ON" onClick="glidres(1)"> 
	</span> 
</form> 
</p></td></tr></table> 


 );

return($line);

}
#-----------------------------------------------------------
# �w�b�_��Javascript����
#-----------------------------------------------------------
sub Head_javascript{

# �錾
my(%init) = &Init();

$main::head_javascript .= qq(
<!--�O���p���b�g--> 
<script type="text/javascript" src="$init{'skin_directory'}palette_selfy.js"></script>);

$main::head_javascript .= q(
<!--�g���c�[��--> 
<script type="text/javascript"><!--
// Header
var phead = 'id=8uolW8Cu&pass=&name=&applet=shipainter&width=300&height=300&anime=1&pchsave=1&painttime=1278320484&ptimeoff=&quality=1&';
// �����ő��M�{�^��
function resubmit(){
	document.paintbbs.pExit();
}
function hinttool(hi){
	document.paintbbs.getInfo().m.iHint = hi;
}
function pentool(p1,p2,p3,p4,p5,p6,p7){
	var dp=document.paintbbs;
	dp.getInfo().m.iPen = p1;
	dp.getInfo().m.iPenM = p2;
	dp.getInfo().m.iAlpha = p3;
//	dp.getInfo().m.iSize = p4;
	dp.getInfo().m.iCount = p5;
	dp.getInfo().m.isCount = p6;
	dp.getInfo().m.isAnti = p7;
}
// ���̃|�C���g���W
var npx,npy; 
var setx=0; var sety=0;	// ���߂̍��W
function nowposition(e){
	var d=document;
	if(d.layers){
		npx=e.pageX;  npy=e.pageY;
	}else if((d.getElementById) && (!d.all)){
		npx=e.pageX;  npy=e.pageY;
	}else if(d.all){
		npx=d.body.scrollLeft+event.clientX;
		npy=d.body.scrollTop+event.clientY;
	}
	d.forms.nowpform.nowpx.value = npx - setx;
	d.forms.nowpform.nowpy.value = npy - sety;
}
// �|�W�V�������Z�b�g
function setposition(e){
	var d=document;
/*
	if(d.layers){
		setx=e.pageX;  sety=e.pageY;
	}else if((d.getElementById) && (!d.all)){
		setx=e.pageX;  sety=e.pageY;
	}else if(d.all){
		setx=d.body.scrollLeft+event.clientX;
		sety=d.body.scrollTop+event.clientY;
	}
*/
	setx = Number(d.forms.nowpform.setpx.value.replace(/[^0-9]/g,''));
	if(!setx){ setx=0; }
	d.forms.nowpform.setpx.value = setx;
	sety = Number(d.forms.nowpform.setpy.value.replace(/[^0-9]/g,''));
	if(!sety){ sety=0; }
	d.forms.nowpform.setpy.value = sety;
}
// �A�v���b�g�t�B�b�g
function appletfit(f){
	var d=document;
	if(!d.all){ return; }
	if(f != 1){
		var cwid = d.body.clientWidth - 260;
		var chei = d.body.clientHeight - 105;
		if(cwid > d.paintbbs.width) { d.paintbbs.width  = cwid; }
		if(chei > d.paintbbs.height){ d.paintbbs.height = chei; }
	}else if("490" && "450"){
		d.paintbbs.width  = "490";
		d.paintbbs.height = "450";
	}
}

// �g��k��
var nowsc=1;
function scale(sc,xx,yy){
	var d=document;
	if(sc == 0.5 || (nowsc<=1 && yy==2)){
		if(nowsc > 1){ d.paintbbs.getMi().scaleChange(1,true); }
		sc=-1;
		d.paintbbs.getMi().scaleChange(sc,false);
		nowsc=0.5;
		if(d.forms.scalf){
			d.forms.scalf.scalx.value = '*'+1;
			d.forms.scalf.scaly.value = '*'+0.5;
		}
	}else{
		if(!sc){ sc=nowsc; }
		if(xx){ sc=nowsc*xx; }
		else if(yy){ sc = Math.floor((nowsc+1)/yy); }
		if(sc < 1){ sc = 1; }else if(sc > 128){ sc = 128; }
		d.paintbbs.getMi().scaleChange(sc,true);
		nowsc=sc;
		var nowsy = 0.5;
		if(nowsc != 1){ nowsy = Math.floor((nowsc+1)/2); }
		if(d.forms.scalf){
			d.forms.scalf.scalx.value = '*'+(nowsc*2);
			d.forms.scalf.scaly.value = '*'+nowsy;
		}
	}
}
// ���W�Ƃ�
var digit=new Array("0","1","2","3","4","5","6","7","8","9","a","b","c","d","e","f");
function getByte(value){
 return digit[(value>>>4)&0xf]+digit[value&0xf];
}
function getShort(value){
 return getByte(value>>>8)+getByte(value&0xff);
}
function getInt(value){
 return getShort(value>>>16)+getShort(value&0xffff);
}
// ���C���[
var len,la,ln,optionlength;
var lname = new Array();
// ���C���[�ǉ�
function layeradd(){
	var dl=document.forms.layerform.layernum;
	len=eval(Number(document.paintbbs.getLSize()));	// ���C���[�̐�
	document.paintbbs.send("iHint=14@"+getInt(1)+getInt(len+1),false);	//����
	len++;
	newselect(len);
	dl.options[0].selected = true;
	layerselect(dl.options[0].value,dl.options[0].text)
}
// ���C���[�폜
function layerdel(){
	var ok = confirm("���X�g�̒��ŁA��ԏ�̃��C���[���폜���܂��B\n�i���ܑI�����Ă��郌�C���[�ł͂���܂���I�j\n��x���C���[���폜����ƁA���ɂ͖߂��܂���B\n����ł���낵���ł����H");
	if(ok){
		var dl=document.forms.layerform.layernum;
		len=eval(Number(document.paintbbs.getLSize()));	// ���C���[�̐�
		if(len<=1){ return; }
		document.paintbbs.send("iHint=14@"+getInt(1)+getInt(len-1),false);	//����
		len--;
		lname[len]='';
		dl.options[len] = null;
		newselect(len);
		dl.options[0].selected = true;
		layerselect(dl.options[0].value,dl.options[0].text)
	}
}
// ���C���[�Z���N�g�̑���
function newselect(lg,v) {
	var dl=document.forms.layerform.layernum;
	if(!lg){ lg=eval(Number(document.paintbbs.getLSize())); }	// ���C���[�̐�
	var lo = dl.options.length;
	if(lg != lo){
		while(dl.options.length>lg){
			dl.options[0]=null; lname[dl.options.length]=''; }
		while(dl.options.length<lg){
			dl.options[dl.options.length]=new Option('--',dl.options.length); }
		for(var l=0;l<lg;l++){
			var la = lg-l-1;
			if(lname[la]){ ln = lname[la]; }else{ ln = 'layer'+la; }
			dl.options[l].value = la;
			dl.options[l].text  = ln;
		}
		if(v){ dl.options[(lg-v-1)].selected = true; }	// select
	}
}
// ���C���[�Z���N�g
function layerselect(v,n) {
	document.paintbbs.getInfo().m.iLayer = v;	// �I�����郌�C���[�ԍ�
	document.forms.layerform.layername.value = n;
	newselect('',v);
}
// ���C���[���ύX
function lnamechange(){
	var dl=document.forms.layerform;
	ln = dl.layernum.options[dl.layernum.selectedIndex];
	ln.text = dl.layername.value;
	lname[ln.value] = dl.layername.value;
}
var header,xy,cls,dfg,wids,heis,katax,katay,longx,longy,rands,randt,i,j,tls,siz,lens,alp,lyr,pen,pem,cnt,qual,gwid,ghei;
// �O���b�h�t�H�[���̓��e�����Ƃ�
function glidres(g){
	qual = 1;
	gwid = 300*qual;
	ghei = 300*qual;
	var dp=document.paintbbs;
	// �A�v���b�g����
	// getcolorz = String(dp.getColors()).split("\\n");
	// cls = Number(getcolorz[0].replace(/\#/,"0x"));
	cls = dp.getInfo().m.iColor;
	alp = dp.getInfo().m.iAlpha;
	siz = dp.getInfo().m.iSize;
	pen = dp.getInfo().m.iPen;
	pem = dp.getInfo().m.iPenM;
	ant = dp.getInfo().m.isAnti;
	cnt = dp.getInfo().m.isCount;
	lyr = dp.getInfo().m.iLayer;
 
	// �t�H�[������
	dfg = document.forms.glidform;
	wids = Number(dfg.widg.value)*qual;
	heis = Number(dfg.heig.value)*qual;
	katax = Number(dfg.cenx.value)*qual;
	katay = Number(dfg.ceny.value)*qual;
 
	lens = Number(dfg.leng.value);
	tls  = Number(dfg.toolg.value);
	if(dfg.randg.checked){ rands = 1; }else{ rands = 0; }
	if(dfg.randl.checked){ randt = 1; }else{ randt = 0; }
 
	// header
	header  = 'iHint='+tls+';iPen='+pen+';PenM='+pem+';iColor='+cls+';iSize='+siz;
//	header += ';isCount='+cnt+';isAnti='+ant;
	header += ';iAlpha='+alp+';iLayer='+lyr+'@';
 
	// �s����
	if(g==1){ syutyu(); }
	else{ glid(); }
}
// �O���b�h���Ђ�
function glid(){
	if(xy==1){
		if(heis){ glidhei(); }
		if(wids){ glidwid(); }
		xy=0;
	}else{
		if(wids){ glidwid(); }
		if(heis){ glidhei(); }
		xy=1;
	}
}
// �O���b�h ��
function glidwid(){
	if(xy==1){
		i=gwid*2;
		wids *= -1;
	}else{
		i=-gwid;
	}
	while((xy!=1 && i<=gwid*2) || (xy==1 && i>=-gwid)){
		if(rands!=1){
			i+=wids;
		}else{
			i = i + Math.floor(Math.random()*wids*2);
		}
		if((xy!=1 && i<=gwid*2) || (xy==1 && i>=-gwid)){  }else{ break; }
		toxi = Math.floor((katax)*lens/100);
		toyi = Math.floor(ghei*lens/100);
		if(randt==1){
			rany = Math.random();
			toxi = Math.floor(toxi*rany);
			toyi = Math.floor(toyi*rany);
		}
		document.paintbbs.send(header + getShort(i)+getShort(0) + getByte(128)+getShort(toxi) + getByte(128)+getShort(toyi),true);
	}
}
// �O���b�h �c
function glidhei(){
	if(xy==1){
		i=ghei*2;
		heis *= -1;
	}else{
		i=-ghei;
	}
	while((xy!=1 && i<=ghei*2) || (xy==1 && i>=-ghei)){
		if(rands!=1){
			i+=heis;
		}else{
			i = i + Math.floor(Math.random()*heis*2);
		}
		if((xy!=1 && i<=ghei*2) || (xy==1 && i>=-ghei)){  }else{ break; }
		toxi = Math.floor(gwid*lens/100);
		toyi = Math.floor(katay*lens/100);
		if(randt==1){
			rany = Math.random();
			toxi = Math.floor(toxi*rany);
			toyi = Math.floor(toyi*rany);
		}
		document.paintbbs.send(header + getShort(0)+getShort(i) + getByte(128)+getShort(toxi) + getByte(128)+getShort(toyi),true);
	}
}
 
 
// �W�������Ђ�
function syutyu(){
	longx = Math.abs(katax) + Math.floor(gwid/2);
	longy = Math.abs(katay) + Math.floor(ghei/2);
	katax += Math.floor(gwid/2);
	katay += Math.floor(ghei/2);
 
	// �h�b�g
	if(lens == 100 && randt != 1){
		document.paintbbs.send(header + getShort(katax)+getShort(katay) + "0100",true);
	}
	if(xy==1){
		if(heis){ linehei(); }
		if(wids){ linewid(); }
		xy=0;
	}else{
		if(wids){ linewid(); }
		if(heis){ linehei(); }
		xy=1;
	}
}
// �W���� ��
function linewid(){
	var a=1; var b=1;
	if(xy==1){
		i=gwid;
		wids *= -1;
	}else{
		i=0;
	}
	j=i;
	while((xy!=1 && i<=gwid) || (xy==1 && i>=0)){
		if(rands==1){	// random up
			j = i + Math.floor(Math.random()*wids*2);
			i = i + Math.floor(Math.random()*wids*2);
			if((xy!=1 && i<=gwid) || (xy==1 && i>=0)){  }else{ break; }
		}
		if(lens != 100){
			a = 1 - (longy*(1-lens/100)) / Math.sqrt((katax-i)*(katax-i)+(ghei-katay)*(ghei-katay));
			b = 1 - (longy*(1-lens/100)) / Math.sqrt((katax-j)*(katax-j)+katay*katay);
		}
		toxi = Math.floor((katax-i)*a);
		toyi = - Math.floor((ghei-katay)*a);
		toxj = Math.floor((katax-j)*b);
		toyj = Math.floor((katay)*b);
		if(randt==1){
			rany = Math.random();
			toxi = Math.floor(toxi*rany);
			toyi = Math.floor(toyi*rany);
			rany = Math.random();
			toxj = Math.floor(toxj*rany);
			toyj = Math.floor(toyj*rany);
		}
		document.paintbbs.send(header + getShort(i)+getShort(ghei) + getByte(128)+getShort(toxi) + getByte(128)+getShort(toyi),true);
		document.paintbbs.send(header + getShort(j)+getShort(0) + getByte(128)+getShort(toxj) + getByte(128)+getShort(toyj),true);
		if(rands!=1){	// normal up
			i+=wids;
			j=i;
		}
	}
}
// �W���� �c
function linehei(){
	var a=1; var b=1;
	if(xy==1){
		i=ghei;
		heis *= -1;
	}else{
		i=0;
	}
	j=i;
	while((xy!=1 && i<=ghei) || (xy==1 && i>=0)){
		if(rands==1){	// random up
			j = i + Math.floor(Math.random()*heis*2);
			i = i + Math.floor(Math.random()*heis*2);
			if((xy!=1 && i<=ghei) || (xy==1 && i>=0)){  }else{ break; }
		}
		if(lens != 100){
			a = 1 - (longx*(1-lens/100)) / Math.sqrt((gwid-katax)*(gwid-katax)+(katay-i)*(katay-i));
			b = 1 - (longx*(1-lens/100)) / Math.sqrt(katax*katax+(katay-j)*(katay-j));
		}
		toxi = - Math.floor((gwid-katax)*a);
		toyi = Math.floor((katay-i)*a);
		toxj = Math.floor((katax)*b);
		toyj = Math.floor((katay-j)*b);
		if(randt==1){
			rany = Math.random();
			toxi = Math.floor(toxi*rany);
			toyi = Math.floor(toyi*rany);
			rany = Math.random();
			toxj = Math.floor(toxj*rany);
			toyj = Math.floor(toyj*rany);
		}
		document.paintbbs.send(header + getShort(gwid)+getShort(i) + getByte(128)+getShort(toxi) + getByte(128)+getShort(toyi),true);
		document.paintbbs.send(header + getShort(0)+getShort(j) + getByte(128)+getShort(toxj) + getByte(128)+getShort(toyj),true);
		if(rands!=1){	// normal up
			i+=heis;
			j=i;
		}
	}
}
// �v���e
function botusend(){
	var okb = confirm("�{�c��Ԃœ��e���܂��B\n�摜�����T�[�o��Ɉꎞ�I�ɕۑ����܂����A\n���O�f�[�^�ɂ͋L�^����܂���B\n\n���e��͓��e�҂������邱�Ƃ��ł����ʂɂ����܂��B\n�����ŃC���[�W��ۑ�������\n�u�폜����v���u����ς蓊�e����v���I��ŁA�Еt���Ă��������B\n��낵���ł����H");
	if(okb){
		document.paintbbs.str_header = phead + 'loot=botusent&nosave=1&';
		resubmit();
	}
}
// �T�C�Y�`�F���W
function sizechange(){
	var m='';
	var w='';
	var h='';
	var a='';
	var qu='';
	var fm='';
	var is='';
	var dpf='';
	var k='';
	var stri='';
	var ok='';
	var djf='1';
	dpf = document.forms.paintform;
	if(dpf.width && dpf.width.value){ w = dpf.width.value; }	// width
	if(dpf.height && dpf.height.value){ h = dpf.height.value; }	// height
	if(dpf.quality && dpf.quality.value){ qu = dpf.quality.value; }	// quality
	if(dpf.mode && dpf.mode.value){ m = dpf.mode.value; }
	else{ m = "shipainter"; }
	if(djf && document.forms.jpngform){
		var djf = document.forms.jpngform;
		if(djf.image_format[0] && djf.image_format[0].checked == true){ fm = 'png';}
		else if(djf.image_format[1] && djf.image_format[1].checked == true){ fm = 'jpg';}
		else if(djf.image_size){ fm = 'each'; is = djf.image_size.value; }
	}
	stri  = 'mode='+m+'&no=&value4=shipainter&nosave=1&value3='+h+'&value2='+w;
	stri += '&value5='+qu+'&value6='+fm+'&value7='+is+'&';	// string
 
	if(dpf.kari){
		if(dpf.kari.value==1){	// anime
			document.paintbbs.str_header = phead + 'loot=sizechanged&value=1&'+stri;
			resubmit();
		}else if(dpf.kari.value==2){	// picture
			var ok = confirm("�摜�����ɁA�ŉ摜��PNG�ŕۑ������ꍇ�́A\n���ɂ���Ă͑�������͕`���Ȃ����Ƃ�����܂��B\nWin+IE�͂قځ~(�ł���ꍇ��)�AMac��NN�Ȃ灛�H\n��낵���ł����H");
			if(ok){
				document.paintbbs.str_header = phead + 'loot=sizechanged&value=2&'+stri;
				resubmit();
			}
		}else{	// paintBBS
			location.href='paint.cgi?'+'mode=shipainter&no=&width=300&height='+h+'&anime=1';
		}
	}else{ alert('forms.paintform.kari ���݂���܂���'); }
}
 
//--></script> 
 
);

}

#----------------------#
#  �A�j���[�V�����\��  #
#----------------------#
sub Viewer{

# �錾
my(%thread,$animation_applet,$print);

# ���O�f�[�^����e��f�[�^���擾
my(%image) = Mebius::Paint::Image("Get-hash Justy",undef,undef,undef,$main::submode3,$main::submode4,$main::submode5);

# �^�C�g����`
if($image{'title'}){ $main::head_link3 = qq(&gt; $image{'title'}); }

# CSS��`
$main::css_text .= qq(
.body1{text-align:center;}
div.image_comment{text-align:left;padding:1em;margin:1em auto;background:#eee;width:$image{'width'}px;}
strong.image_title{font-size:140%;}
div.ads1{margin:2em 0em;}
form{margin:1em 0em;}
);

	# �f�[�^����^�C�g�����`
	if($image{'title'}){
			if($main::submode2 eq "animation"){ $main::sub_title = qq(�h$image{'title'}�h�̃A�j���[�V���� | ���r���G����);  }
			else{ $main::sub_title = qq($image{'title'} | ���r���G����); }
	}

# �폜�ς݂̏ꍇ
if($image{'deleted'} && !$main::admin_mode){ main::error("���̉摜�͍폜�ς݂ł��B �폜�ҁF $image{'delete_person'} �폜�����F $image{'delete_date'}","410 Gone"); }

# �t�@�C���̗L�����`�F�b�N
if(!$image{'image_ok'} && !$main::admin_mode){ main::error("�f�[�^�����݂��܂���B"); }

	# �A�j���[�V�����p�̃A�v���b�g���擾
	if($main::submode2 eq "animation"){
		($animation_applet) = &Animation_applet("",%image);
	}


# �G�̃^�C�g��
if($image{'title'}){ $print .= qq(<strong class="image_title">$image{'title'}</strong>); }

	# �摜���폜�ς݂̏ꍇ
	if($image{'deleted'}){
		$print .= qq(<br$main::xclose><br$main::xclose>);
		$print .= qq(<span class="red">���폜�ς݉摜�ł��B�Ǘ��҂ɂ����\\�����Ă��܂��B�폜�ҁF $image{'delete_person'} �폜�����F $image{'delete_date'}</span><br$main::xclose><br$main::xclose> <img src="$image{'image_url_deleted'}" alt="���G�����摜" style="width:$image{'width'};height:$image{'height'};" alt="�ꎞ�ۑ����ꂽ�G"><br$main::xclose><br$main::xclose>);
	}

	# �摜����
	else{
		$print .= qq(<br$main::xclose><br$main::xclose>);
		$print .= qq(<img src="$image{'image_url'}" alt="���G�����摜" style="width:$image{'width'};height:$image{'height'};" alt="�ꎞ�ۑ����ꂽ�G"><br$main::xclose><br$main::xclose>);
	}

	# �A�j���[�V��������
	if($image{'key'} =~ /Animation/ && $main::submode2 eq "viewer"){
			if($main::admin_mode){
				$print .= qq([ <a href="$main::script?mode=pallet-animation-$main::submode3-$main::submode4-$main::submode5#ANIMATION">�A�j���[�V����</a> ]);
			}
			else{
				$print .= qq([ <a href="./pallet-animation-$main::submode3-$main::submode4-$main::submode5.html#ANIMATION">�A�j���[�V����</a> ]);
			}
		$print .= qq(<br$main::xclose><br$main::xclose>\n);
	}

$print .= qq(<div class="image_data medium_height">);

	# ��Җ�
	if($image{'handle'}){
		$print .= qq( ��ҁF );
		$print .= qq($image{'handle'});
			if($image{'trip'}){ $print .= qq(��$image{'trip'}); }
		$print .= qq(<br$main::xclose>);
	}


	# �e��f�[�^
	if($image{'steps'}){ $print .= qq(�@�X�e�b�v���F $image{'all_steps'}); }
	if($main::myadmin_flag >= 5){ $print .= qq( / $image{'steps'} ); }
	if($image{'all_painttime'}){
		my($all_paint_time) = Mebius::SplitTime(undef,$image{'all_painttime'});
		$print .= qq(�@�`�掞�ԁF $all_paint_time);
	}
	if($image{'thread_url'}){
		(%thread) = Mebius::BBS::thread({},$image{'realmoto'},$image{'postnumber'});
			if($image{'realmoto'} !~ /^sc/){
				$print .= qq(�@ ���L���F <a href="$image{'thread_url'}">$thread{'subject'}</a>);
			}
	}
	if($image{'res_url'}){
			if($image{'realmoto'} !~ /^sc/){
		$print .= qq( ( <a href="$image{'res_url'}">���X</a> ));
			}
	}

$print .= qq(</div>);

# �摜�̐�����
if($image{'comment'}){ $print .= qq(<div class="image_comment">$image{'comment'}</div>); }

	# �폜�t�H�[��
	if($main::admin_mode){

		$print .= qq(<form action="${main::main_url}"><div>\n);
		
			# �폜�ς݂̏ꍇ
			if($image{'deleted'}){
				$print .= qq(<input type="radio" name="delete_type" value="revive" id="image_revive">);
				$print .= qq( <label for="image_revive"><span class="blue">�摜�𕜊�</span></label>\n);
			}

			# ���폜�̏ꍇ
			else{
				$print .= qq(<input type="radio" name="delete_type" value="delete" id="image_delete">);
				$print .= qq( <label for="image_delete">�摜���폜</label>\n);
				$print .= qq(<input type="radio" name="delete_type" value="penalty" id="image_penalty">);
				$print .= qq( <label for="image_penalty"><span class="red">�摜���폜(�y�i���e�B)</span></label>\n);
			}

		$print .= qq(<input type="hidden" name="mode" value="pallet">\n);
		$print .= qq(<input type="hidden" name="type" value="image_delete">\n);
		$print .= qq(<input type="hidden" name="realmoto" value="$image{'realmoto'}">\n);
		$print .= qq(<input type="hidden" name="postnumber" value="$image{'postnumber'}">\n);
		$print .= qq(<input type="hidden" name="resnumber" value="$image{'resnumber'}">\n);
			if($main::in{'backurl'} && $main::backurl){
				 $print .= qq($main::backurl_input\n);
				$print .= qq(<input type="submit" name="allow_backurl" value="���s����(��)" class="back">\n);
			}
		$print .= qq(<input type="submit" value="���s����">\n);
		$print .= qq(</div></form>\n);
	}


# �L��
my $ads = qq(
<div class="ads1">
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
</div>
);

	if(!$main::admin_mode){ $print .= qq($ads); }


$print .= qq($animation_applet);


Mebius::Template::gzip_and_print_all({},$print);


exit;


}


#-----------------------------------------------------------
# �A�j���[�V�����\���̂��߂̃A�v���b�g���`
#-----------------------------------------------------------
sub Animation_applet{

# �Ǐ���
my($type,%image) = @_;
my(%init) = &Init();
my($line,$applet_width,$applet_height);

	# ���^�[������ꍇ
	if(!-f $image{'animation_file'}){ return(); }
	if(!$main::admin_mode && $image{'key'} !~ /Animation/){ return(); }

# �A�v���b�g�̃T�C�Y
$applet_width = $image{'width'};
$applet_height = $image{'height'} + 26;

#<param name="pch_file" value="$image{'animation_url'}">

# HTML����
$line .= qq(
<div class="animation" id="ANIMATION">
�A�j���[�V�����F<br$main::xclose><br$main::xclose>

<!--����������A�v���b�g--> 
<applet mayscript code="pch2.PCHViewer.class" archive="$init{'skin_directory'}PCHViewer.jar" name="pchapp" width="$applet_width" height="$applet_height"> 
<param name="pch_file" value="$image{'animation_url'}">

<param name="buffer_canvas" value="false">
<param name="buffer_progress" value="false">
<param name="dir_resource" value="$init{'skin_directory'}">
<param name="image_height" value="$image{'width'}">
<param name="image_width" value="$image{'height'}">

<param name="progress" value="true">
<param name="res.zip" value="$init{'skin_directory'}res_normal.zip">
<param name="run" value="true">
<param name="speed" value="0">
<param name="tt.zip" value="$init{'skin_directory'}tt.zip">

 	<!--APPLET_STYLE_PARAM--> 
 
	<!--�A�v���b�g--> 
	<param name="image_bkcolor" value="">	<!--�L�����o�X�̔w�i�F--> 
	<param name="image_bk" value="">	<!--�A�v���b�g�̔w�i�̃C���[�W(�^�C������\��)--> 
	<param name="color_text" value="#8099b3">	<!--�A�v���b�g�̃e�L�X�g�J���[--> 
	<param name="color_bk" value="#ffffff">	<!--�A�v���b�g�̔w�i�J���[--> 
	<param name="color_bk2" value="#ccddee">	<!--�A�v���b�g�̖ԏ�̐��̃J���[--> 
	<!--�A�C�R��--> 
	<param name="color_icon" value="#eef3f9">	<!--�A�C�R���̃J���[--> 
	<param name="color_frame" value="#ccddee">	<!--�A�C�R���̘g�̃J���[--> 
	<param name="color_iconselect" value="#ffccb3">	<!--�A�C�R����I�����o��g�̃J���[--> 
	<!--�X�N���[���o�[--> 
	<param name="color_bar" value="#ccddee">	<!--�o�[�̃J���[--> 
	<param name="color_bar_hl" value="#aaccee">	<!--�o�[�̃n�C���C�g�J���[ --> 
	<param name="color_bar_frame_hl" value="#ffffff">	<!--�o�[�̃t���[���̃n�C���C�g--> 
	<param name="bar_size" value="20">	<!--�o�[�̑���--> 
	<!--�c�[���o�[--> 
	<param name="tool_color_button" value="#fffafa">	<!--�{�^���̐F��--> 
	<param name="tool_color_button2" value="#fffafa">	<!--�{�^���̐F��--> 
	<param name="tool_color_text" value="#806650">	<!--�e�L�X�g�̐F--> 
	<param name="tool_color_bar" value="#fffafa">	<!--�ύX�o�[�̐F--> 
	<param name="tool_color_frame" value="#808080">	<!--�g�̐F--> 
	<!--/APPLET_STYLE_PARAM--> 
</applet> 
</div>
<br$main::xclose>
<br$main::xclose>
);

# �g���Ă��Ȃ��R���g���[���p�l��

my $applet_control = qq(
<table style="margin:auto;"><tr><td align="center"> 
	<small><br> 
	<span title="�������������Ȃ�قǑ����B"> 
	�Đ����x : </span> 
	<input type="text" id="speedy" name="speed" value="0" size=3 
		style="text-align:center" onblur="playspeed(0,this.value)"> 
	<input type="button" value="��" title="�X�s�[�hUP" onClick="playspeed(1)"> 
	<input type="button" value="��" title="�X�s�[�hDOWN" onClick="playspeed()"> 
	</small><br> 
	<small> 
	���C���[�� : 
	<font title="layer_count">3</font> 
	/ 
	<font title="layer_max"></font> 
	/ 
	<font title="layer_last"></font> 
	,
	�N�I���e�B�l : 
	<font title="�N�I���e�B�l">1</font> 
	<br> 
	�T�C�Y : 
	<font title="��">$image{'width'}</font> 
	x
	<font title="����">$image{'height'}</font> 
	px /
	<font title="�A�j���[�V�����t�@�C���̑傫��">? kb</font> 
	</small> 
</td></tr></table> 
);

return($line);

}


1;
