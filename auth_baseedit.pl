#-------------------------------------------------
# �ҏW�����s - �}�C�A�J�E���g
#-------------------------------------------------
sub auth_baseedit{

# �Ǐ���
my($line,$bkline,$max_bkup,$bki);

# �Ǘ��҂̂�
if($myadmin_flag < 5){ &error("�s���ȏ����ł��B") }

# �A�N�Z�X����
&axscheck("");

# �����`�F�b�N
$file = $in{'account'};
$file =~ s/[^0-9a-z]//;
if($file eq ""){ &error("�l��ݒ肵�Ă��������B"); }

# �f�B���N�g���쐬
&Mebius::Mkdir("","${int_dir}_id/$file",$dirpms);

# �^�C�g���Ȃǒ�`
$head_link3 = "&gt; ����ҏW";

# �A�J�E���g�t�@�C�����J��
if($server_domain eq $auth_domain || -e "${int_dir}_id/$file/$file.cgi"){ &open($file); }

# ���b�N�J�n
&lock("auth$file") if($lockkey);

# �A�J�E���g���C�p�X����v���Ȃ��ꍇ�G���[
if(!$idcheck){ &error("�ҏW����ɂ̓��O�C�����Ă��������B"); }

# �A�J�E���g���b�N�i�폜�j�̏ꍇ�A�V�K�A�J�E���g�쐬���u���b�N
if($in{'ppkey'} eq "0" || $in{'ppkey'} eq "2"){ &block_anewmake($file); }

# �A�J�E���g��~�̏ꍇ�A�R�����g�ݒ��ύX
if($in{'ppkey'} eq "0" || $in{'ppkey'} eq "2"){
$ppobbs = "0";
$ppodiary = "0";
$ppocomment = "0";
}


# �ύX���e�̒�`

if($in{'ppkey'} ne ""){
$ppkey = $in{'ppkey'};
$ppkey =~ s/\D//g;
}

if($in{'pplevel'} ne ""){
$pplevel = $in{'pplevel'};
$pplevel =~ s/\D//g;
}

if($in{'pplevel2'} ne ""){
$pplevel2 = $in{'pplevel2'};
$pplevel2 =~ s/\D//g;
}

if($in{'ppadmin'} ne ""){
$ppadmin = $in{'ppadmin'};
$ppadmin =~ s/\D//g;
}


if($in{'ppsurl'} ne ""){
$ppsurl = $in{'ppsurl'};
}

if($in{'ppchat'} ne ""){
$ppchat = $in{'ppchat'};
$ppchat =~ s/\D//g;
}

if($in{'ppblocktime'} ne ""){
$ppblocktime = $in{'ppblocktime'};
$ppblocktime =~ s/\D//g;
}
if($in{'ppblocktime'} eq "none"){ $ppblock_time = ""; }

$ppreason = $in{'ppreason'};
$ppreason =~ s/\D//g;

$ppadlasttime = $time;

# �ҏW���s
require "${int_dir}auth_seditprof.pl";
&seditprof($file);


# ���b�N����
&unlock("auth$file") if($lockkey);

	# ���_�C���N�g(�P���)
	if($mebi_mode && !$in{'moved'} && !$alocal_mode){
		if($alocal_mode){ &Mebius::Redirect("","http://localhost/_auth/?$postbuf&moved=1\n\n"); }
		else{ &Mebius::Redirect("","http://aurasoul.mb2.jp/_auth/?$postbuf&moved=1"); }
		exit;
	}

	# ���_�C���N�g(�Q���)
	else{
		my $redirect_url = "${auth_url}${file}/#BASEEDIT";
		if($in{'backurl'}){ $redirect_url = $backurl; }
		&Mebius::Redirect("",$redirect_url);
	}

# �ҏW��A�y�[�W�W�����v
$jump_sec = $auth_jump;
$jump_url = qq(${auth_url}${file}/#BASEEDIT);
if($aurl_mode){ $jump_url = "$script?account=$file#BASEEDIT"; }

# �w�b�_
&header();

# HTML
print <<"EOM";
<div class="body1">
�ҏW���܂����B
<a href="$jump_url">�A�J�E���g</a>�ֈړ����܂��B<br>
</div>
EOM

# �t�b�^
&footer;

# �����I��
exit;

}

#-----------------------------------------------------------
# �V�K�A�J�E���g�쐬���u���b�N
#-----------------------------------------------------------
sub block_anewmake{

my($file) = @_;

# ���O�C���������J��
open(RLOGIN_IN,"${int_dir}_id/$file/${file}_rlogin.cgi");
while(<RLOGIN_IN>){
chomp;
my($lasttime,$xip_enc2,$host2,$number,$id) = split(/<>/);
if($number ne ""){ &block_cnumber($number); }
if($xip_enc2 ne ""){ &block_xip($xip_enc2); }
}
close(RLOGIN_IN);


# �N�b�L�[�u���b�N ---------------------
sub block_cnumber{
my($file) = @_;
my $line = qq(9999999999999999<>\n);
open(CFILE_OUT,">${ip_dir}_ip_cidmake/$file.cgi");
print CFILE_OUT $line;
close(CFILE_OUT);
chmod($logpms,"${ip_dir}_ip_cidmake/$file.cgi");
}

# �w�h�o�u���b�N ---------------------
sub block_xip{
my($file) = @_;
my $line = qq(9999999999999999<>\n);
open(XIP_OUT,">${ip_dir}_ip_idmake/$file.cgi");
print XIP_OUT $line;
close(XIP_OUT);
chmod($logpms,"${ip_dir}_ip_idmake/$file.cgi");
}

}


1;

