package main;

#-------------------------------------------------
# �v���t�B�[���\��
#-------------------------------------------------
sub auth_spform{

# �Ǐ���
my($file);
our($myadmin_flag);

#�����`�F�b�N
$file = $in{'account'};
$file =~ s/[^0-9a-z]//g;

# ���ɃX�y�V���������o�[�̏ꍇ
if($main::myaccount{'level2'} >= 1 && !$myadmin_flag){ &error("���Ȃ��͊��ɃX�y�V��������ł��B"); }

# ���O�C�����Ă��Ȃ��ꍇ
if(!$idcheck){ &error("���̃y�[�W�𗘗p����ɂ́A���O�C�����Ă��������B"); }

# CSS��`
$css_text .= qq(
li{line-height:1.5em;}
.url{width:20em;}
.spimg{}
a:active { color: yellow; }
);

# �^�C�g������
$sub_title = "�X�y�V���������o�[�\\�� - $title";
$head_link3 = qq(&gt; �X�y�V���������o�[�\\��);

# �\������
if($in{'action'}){ &auth_spform_send_action(); }
elsif($main::in{'type'} eq "checked" && $main::myadmin_flag){ &auth_spmember_apply_file("Renew Be-checked-apply",$main::in{'hash'}); }

# �Ǘ��҂̕\��
if($myadmin_flag){ &auth_spform_admin_view(); }



# �i�r
my $link2 = "$adir${file}/";
if($aurl_mode){ ($link2) = &aurl($link2); }
my $navilink .= qq(<a href="$link2">�v���t�B�[����</a>);

# HTML
my $print = <<"EOM";
$footer_link
<h1>�X�y�V���������o�[�\\��</h1>

<h2>����</h2>

���r�E�X�����O�ł́A�T�[�o�[���ׂȂǂ̎���ɂ��A�F�X�Ȑ���������܂����A<br>
<strong class="red">�z�[���y�[�W��u���O�ȂǂŁA���r�E�X�����O���Љ�Ă�����������</strong>�Ɍ����āA<br>
�X�y�V���������o�[�Ƃ��āA���̃{�[�i�X���󂯂邱�Ƃ��o���܂��B<br><br>

<h3>�{�[�i�X</h3>

<ul>
<li><a href="$auth_url">�r�m�r</a>�Ƀ��O�C�����A���ʂ̌f����<strong class="red">�҂����Ԃ��Z�k</strong>����܂��B</li>
<li>���Ȃ��̃A�J�E���g�ŁA$friend_tag�ɓo�^�ł���l���������܂��B</li>
<li>���Ȃ�����$friend_tag�\\������ꍇ�̑҂����Ԃ����Ȃ��Ȃ�܂��B</li>
</ul>

<br>

���Ȃ��̃T�C�g�ł���΁A�Љ�̕��@�͖₢�܂���B<br>
�u���O�̂P�L���Ƃ��ďЉ����A�����N�W�ɓ��ꂽ��Ǝ��R�ł��B<br><br>

<a href="http://www.google.com/support/webmasters/bin/answer.py?answer=66736&amp;query=%E6%9C%89%E6%96%99&topic=&amp;type=">�������N��\\��ꍇ�́urel="nofollow"�v�̑������g�����Ƃ��������߂��܂�</a><br><br>

<strong>�Љ�̈��</strong>�@<span class="red">����Ȃ̂ŁA���̒ʂ�łȂ��Ă����܂��܂���B</span><br><br>
<a href="http://auraneed.blog98.fc2.com/blog-entry-7.html"><img src="http://mb2.jp/pct/spform1.bmp" alt="�Љ�̈��" class="spimg"></a><br><br><br>

�X�y�V���������]�̕��́A���̃t�H�[���ŁA<br>
<strong class="red">���r�E�X�����O���Љ���y�[�W�̂t�q�k</strong>�������M���������B


<form action="$action" method="post">
<input type="text" name="url" value="http://" class="url">
<input type="hidden" name="mode" value="spform">
<input type="hidden" name="action" value="1">

<input type="submit" value="���̓��e�Ő\\������" disabled> �����݁A��W��~���ł��B
</form>

�Ǘ��҂ɂ��R���ɒʂ�ƁA�X�y�V���������o�[�Ƃ��ēo�^����܂��B<br><br>

<h2 id="HOSOKU">�⑫</h2>

<ul>
<li>���T�͍���A�C���A�ǉ��A�폜�����\\��������܂��B</li>
<li>�Љ�y�[�W�������Ă��܂����Ƃ���A�T�C�g���������Ă��܂����ꍇ�́A�o�^����������邱�Ƃ�����܂��B</li>
<li>���r�E�X�����O��r�m�r�ł̃��[���ᔽ�ɂ��A�o�^����������邱�Ƃ�����܂��B</li>
<li>�\\�����ꂽ�y�[�W��T���Ă��A�����Љ������Ȃ��ꍇ�A�o�^����Ȃ����Ƃ�����܂��B</li>
<li>���̂悤�Ȑ\\���́A�o�^����܂���B�u�A�_���g�T�C�g�v�u�o��n�v�u�f���ł̏Љ�v�u�l�̃T�C�g�ł̏Љ�v�u������T�C�g�ł̏Љ�v�B</li>
<li>���̂悤�Ȑ\\���́A�o�^����Ȃ��ꍇ������܂��B�u�񎟑n��̂���T�C�g�v�u�R���e���c�i���e�j�����Ȃ��T�C�g�v�u�\\���A�����\\���Ȃǂ�����T�C�g�v�u���ɓI�ȏЉ�A���ӂ̂���Љ�v�B</li>
<li>�\\���͉��x�ł��\\�ł��B</li>
</ul>
$adline
$footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);

# �����I��
exit;

}

#-----------------------------------------------------------
# �\������
#-----------------------------------------------------------

sub auth_spform_send_action{

# �Ǐ���
my($line,$file_handler1);

# �A�N�Z�X����
main::axscheck("Post-only");

# URL�̃`�F�b�N
$in{'url'} =~ s/ //g;
	if($in{'url'} eq "" || $in{'url'} eq "http://"){ &error("�t�q�k���J���ł��B"); }
$http_num = ($in{'url'} =~ s/http:\/\//$&/g);
	if($http_num >= 2){ &error("http:// ��2�ȏ㏑����Ă��܂��B"); }
	foreach(@domains){
	if($in{'url'} =~ /^http:\/\/$_/){ &error("���r�E�X�����O���̂t�q�k�ł́A�Љ�����ƂɂȂ�܂���B"); }
	}
	if($in{'url'} !~ /^http/){ &error("http://~ �Ŏn�܂�t�q�k����͂��Ă��������B"); }
	unless($in{'url'} =~ /\.([a-z]+)/){ &error("�������t�q�k�̌`���œ��͂��Ă��������B"); }
	unless($in{'url'} =~ /(\.jp|\.com|\.net)/){ &error("�������t�q�k�̌`���œ��͂��Ă��������B"); }
	if($in{'url'} =~ /(bbs|chat|aura|mb2|youtube|2ch\.net|nicovideo\.jp|twitter\.(com|jp)|\@|\?search)/){ &error("�t�q�k�� $1 ���܂ރy�[�W�͐\\���ł��܂���B"); }

# �X�e�[�^�X�R�[�h���`�F�b�N
my($code) = &get_status($in{'url'});
if($code ne "200"){ &error("$code - �\\���t�q�k��������Ȃ��A�܂��̓p�X���[�h���̂��ߐ\\���ł��܂���B�t�q�k���������Ă�����x�\\�����Ă��������B"); }

# �\���t�@�C�����X�V
main::auth_spmember_apply_file("New-apply Renew",$main::myaccount{'file'},$main::in{'url'});

# ���[�����M
Mebius::send_email("To-master",undef,"�r�o����\\�����͂��܂���","�Ǘ�: http://mb2.jp/_auth/spform.html\n\nURL: $in{'url'}");



# HTML
my $print = <<"EOM";

�\\�����肪�Ƃ��������܂����B<br>
���r�E�X�����O���Љ�Ă����������̂́A���̂t�q�k�ŗǂ������m�F���������i�t�q�k�ԈႢ�̏ꍇ�́A�đ��M�\\�ł��j�B<br><br>

<a href="$in{'url'}">$in{'url'}</a><br><br>

<br>�Ǘ��҂ɂ��R���ɒʉ߂���ƁA�X�y�V��������Ƃ��ēo�^���������܂��B<br>
�P�T�ԁ`�P�����قǂ��҂����������i<a href="$auth_url">��$title�ɖ߂�</a>�j�B<br>
$footer_link2
EOM


Mebius::Template::gzip_and_print_all({},$print);

# �I��
exit;

}

use strict;

#-----------------------------------------------------------
# �o�^�t�@�C��
#-----------------------------------------------------------
sub auth_spmember_apply_file{

# �錾
my($type) = @_;
my(undef,$account,$new_url) = @_ if($type =~ /New-apply/);
my(undef,$hash) = @_ if($type =~ /Be-checked/);
my($file_handler1,@line,$adline,$i,$action);
my($auth_log_directory) = Mebius::SNS::all_log_directory_path() || die;

my $file = "${auth_log_directory}splog.cgi";

# �t�@�C�����J��
open($file_handler1,"<",$file);

	# �t�@�C�����b�N
	if($type =~ /Renew/){ flock($file_handler1,1); }

	while(<$file_handler1>){

		# ����
		chomp;
		my($account2,$url2,$date2,$hash2,$key2) = split(/<>/,$_);

			# �C���f�b�N�X���擾
			if($type =~ /Get-index/){

				my($red,%account,$anchor_style);

				$i++;

				my($prev) = $i + 1;
				my($next) = $i - 1;

				my($account,$url,$date2) = split(/<>/,$_);
				my $link = qq($main::adir$account/);


				if($i < 500){ (%account) = Mebius::Auth::File("Hash Not-keycheck",$account); }

				if($main::submode2 ne "all" && $i >= 200){ $adline .= qq(<br><a href="spform-all.html">���S�ĕ\\��</a><br>); last; }

				if($account{'level2'} >= 1){ $red = qq( class="ok"); }

				my($style1);
					if($key2 =~ /Checked-apply/){ $style1 = qq( style="background:#fdd;"); }
					elsif($i % 2 == 1){ $style1 = qq( style="background-color:#ddd;"); }

				#my($anchor_style);
				#if($submode2 eq $i){ $anchor_style = qq( style="color:#f00;"); }

				$adline .= qq(
				<form action="$action" method="post" class="inline">
				<div id="S$i"$style1>
				$i. <a href="$link"$red$anchor_style>$account{'name'} - $account</a> - <a href="$url"$red$anchor_style>$url</a> $date2
				<input type="hidden" name="mode" value="baseedit">
				<input type="hidden" name="account" value="$account">
				<input type="hidden" name="pplevel2" value="1">
				<input type="hidden" name="ppsurl" value="$url">
				<input type="hidden" name="backurl" value="${main::auth_url}$main::myaccount{'file'}/spform-$next#S$next">
				<input type="submit" value="�ݒ�">);

				# �t���[���\��
				#if($submode2 eq $i){ 
				#$adline .= qq(
				#<a href="spform-$next#S$next">��</a>
				#<a href="spform-$prev#S$prev">��</a>
				#<iframe src="$url" style="width:100%;height:500px;"></iframe>
				#);
				#}
				#else{
				#$adline .= qq( <a href="spform-$i#S$i">�t���[��</a>);
				#}

				$adline .= qq(</form>\n);

				$adline .= qq(<form action="./#S$next" method="post" class="inline">\n);
				$adline .= qq(<input type="hidden" name="mode" value="$main::mode">\n);
				$adline .= qq(<input type="hidden" name="type" value="checked">\n);
				$adline .= qq(<input type="hidden" name="hash" value="$hash2">\n);
				$adline .= qq(<input type="submit" value="�m�F">\n);
				$adline .= qq(</form>\n);

				$adline .= qq(</div>\n);

				# �t���[���\��

			}

			# �V�K�\������ꍇ
			if($type =~ /New-apply/){

					if($account2 eq $account && $url2 eq $new_url){
						close($file_handler1);
						&error("���̂t�q�k�͐\\���ς݂ł��B");
					}

			}

			# �m�F����ꍇ
			if($type =~ /Be-checked/){

					if($hash2 && $hash2 eq $hash){
						$key2 =~ s/(\s)?Checked-apply//g;
						$key2 .= qq( Checked-apply);
					}

			}

			# �X�V����ꍇ
			if($type =~ /Renew/){

					if(!$hash2){ $hash2 = Mebius::Crypt::char(); }

				push(@line,"$account2<>$url2<>$date2<>$hash2<>$key2<>\n")

			}
	


	}
close($file_handler1);

	# �V�����s��ǉ�
	if($type =~ /New-apply/){
		my $new_hash = Mebius::Crypt::char();
		unshift(@line,"$account<>$new_url<>$main::date<>$new_hash<>\n");
	}


	# �t�@�C���ɏ�������
	if($type =~ /Renew/){
		Mebius::Fileout(undef,$file,@line);
	}

	# �C���f�b�N�X�擾�p
	if($type =~ /Get-index/){
		return($adline);
	}


}

no strict;

#-----------------------------------------------------------
# �Ǘ��҂̕\��
#-----------------------------------------------------------

sub auth_spform_admin_view{

# �Ǐ���
my($i,$spfile_handler);

$css_text .= qq(
.ok{color:#bbb;}
);

($adline) = &auth_spmember_apply_file("Get-index");



if($adline){ $adline = qq(<h2>�\\���ꗗ�i�Ǘ��җp�j</h2>$adline); }

}


1;
