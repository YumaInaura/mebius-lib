
#-------------------------------------------------
# �ҏW�����s - �}�C�A�J�E���g
#-------------------------------------------------
sub auth_editprof{

# �Ǐ���
my($change_name_flag,$redirect_flag);

# ���[�h����
if($in{'type'} eq "cancel_mail"){ require "${int_dir}auth_cancelmail.pl"; }
if($in{'type'} eq "get"){ require "${int_dir}auth_editprof2.cgi"; }

# �A�N�Z�X����
&axscheck("NOLOCK");

# �J���t�@�C�����`
if($in{'account'} && $myadmin_flag){ $file = $in{'account'}; }
else{ $file = $pmfile; }

# �����`�F�b�N
$file =~ s/[^0-9a-z]//;
if($file eq ""){ &auth_editprof_error("���O�C�����Ă��������B"); }

# �G���[���̒ǉ��\��
$fook_error = qq(<strong>���M���e�F</strong><br><br>�M���F$in{'name'}<br><br>$in{'prof'});

# �ҏW���[�h�A�J���t�@�C����I��
$edit_flag = 1;

# �^�C�g���Ȃǒ�`
$head_link3 = "&gt; �ҏW";

# �h���C���u���b�N
if(!$postflag){ &auth_editprof_error("�f�d�s���M�͏o���܂���B"); }
if($server_domain ne $auth_domain){ &auth_editprof_error("�T�[�o�[���Ⴂ�܂��B"); }

# ID�A�g���b�v�t�^
&trip($in{'name'});
&id();

# �e��`�F�b�N
require "${int_dir}regist_allcheck.pl";
($in{'name'}) = &name_check($in{'name'});
($in{'prof'}) = &all_check($in{'prof'});

# �A�J�E���g���J��
&open($file);

# �ҏW���e�̏���
my $length = int(length($in{'prof'}));
if($length > 5000*2){ $e_error .= qq(���v���t�B�[�����������܂��B( $length���� / 5000���� )<br>); $emd++; }
if($in{'prof'} =~ /�O��/ && $in{'prof'} =~ /([0-9]{8,})/){ $e_error .= qq(���O���v���t�B�[���̂h�c���������܂Ȃ��ł��������B<br>); $emd++; }
if($pmkey eq "2" && $in{'prof'} ne ""){ $e_error .= qq(���A�J�E���g�����b�N����Ă���ꍇ�A�v���t�B�[�������S�ɍ폜���Ȃ���΁A�ݒ�ύX�ł��܂���B<br>); $emd++; }

# �G���[�ƃv���r���[
&error_view("AERROR Target","auth_editprof_error");

# ���b�N�J�n
&lock("auth$file") if($lockkey);

# �A�J�E���g�t�@�C�����J��
&open($file);

# ���_�C���N�g����ꍇ
if($pporireki ne $in{'pporireki'}){ $redirect_flag = 1; }

# �M���ύX���`�F�b�N
if($in{'name'} ne $ppname){ $change_name_flag = 1; }

# �����̃A�J�E���g�ȊO�͕ҏW�ł��Ȃ�
if(!$myprof_flag && !$myadmin_flag){ &auth_editprof_error("�����̃A�J�E���g�ȊO�ҏW�ł��܂���B"); }

# �����A�h�F��
if($in{'email'}){
require "${int_dir}main_sendcermail.cgi";
&send_cermail($in{'email'});
}

# �A�J�E���g���C�p�X����v���Ȃ��ꍇ�G���[
if(!$idcheck){ &auth_editprof_error("�ҏW����ɂ̓��O�C�����Ă��������B"); }

$in{'ppocomment'} =~ s/\D//g;
if(length($in{'ppocomment'}) >= 4){ &auth_editprof_error("�ݒ�l���ςł��B"); }
elsif($in{'ppocomment'} > 4){ &auth_editprof_error("�ݒ�l���ςł��B"); }

$in{'ppodiary'} =~ s/\D//g;
if(length($in{'ppodiary'}) >= 2){ &auth_editprof_error("�ݒ�l���ςł��B"); }
elsif($in{'ppodiary'} > 2){ &auth_editprof_error("�ݒ�l���ςł��B"); }

$in{'ppobbs'} =~ s/\D//g;
if(length($in{'ppobbs'}) >= 2){ &auth_editprof_error("�ݒ�l���ςł��B"); }
elsif($in{'ppobbs'} > 2){ &auth_editprof_error("�ݒ�l���ςł��B"); }

$in{'pposdiary'} =~ s/\D//g;
if(length($in{'pposdiary'}) >= 2){ &auth_editprof_error("�ݒ�l���ςł��B"); }
elsif($in{'pposdiary'} > 2){ &auth_editprof_error("�ݒ�l���ςł��B"); }
if($pplevel < 1 && $mebi_mode){ $in{'pposdiary'} = ""; };

$in{'pposbbs'} =~ s/\D//g;
if(length($in{'pposbbs'}) >= 2){ &auth_editprof_error("�ݒ�l���ςł��B"); }
elsif($in{'pposbbs'} > 2){ &auth_editprof_error("�ݒ�l���ςł��B"); }
if($pplevel < 1 && $mebi_mode){ $in{'pposbbs'} = ""; };

$in{'pporireki'} =~ s/\D//g;
if(length($in{'pporireki'}) >= 2){ &auth_editprof_error("�ݒ�l���ςł��B"); }
elsif($in{'pporireki'} > 2){ &auth_editprof_error("�ݒ�l���ςł��B"); }

$in{'ppcolor1'} =~ s/\W//g;
if(length($in{'ppcolor1'}) > 3){ &auth_editprof_error("�ݒ�l���ςł��B"); }

$in{'ppcolor2'} =~ s/\W//g;
if(length($in{'ppcolor2'}) > 3){ &auth_editprof_error("�ݒ�l���ςł��B"); }

# �����A�h����
if($ppmlpass eq ""){ $ppemail = $in{'email'}; }
if($in{'reset_email'}){ $ppemail = ""; $ppmlpass = ""; }

# �����̃v���t�B�[���̏ꍇ
if($myprof_flag){ $ppencid = $encid; }

# �ύX���e�̒�`
my $put_ppprof = $in{'prof'};
$ppmtrip = $i_trip;
$ppname = $i_handle;
$ppenctrip = $enctrip;

$ppcolor1 = $in{'ppcolor1'};
$ppcolor2 = $in{'ppcolor2'};

$ppocomment = $in{'ppocomment'};
$ppodiary = $in{'ppodiary'};

$ppobbs = $in{'ppobbs'};
$pposdiary = $in{'pposdiary'};
$pposbbs = $in{'pposbbs'};

$pporireki = $in{'pporireki'};


# �ҏW���s
require "${int_dir}auth_seditprof.pl";
&seditprof($file);

# �v���t�B�[���ҏW���s
open(PROF_OUT,">${int_dir}_id/$file/${file}_prof.cgi");
print PROF_OUT qq($put_ppprof<>\n);
close(PROF_OUT);
chmod($logpms,"${int_dir}_id/$file/${file}_prof.cgi");

# �M�������̍X�V
&auth_renew_namefile($file);

# ���b�N����
&unlock("auth$file") if($lockkey);

# �M���ύX�̏ꍇ�A�S�A�J�E���g�t�@�C�����X�V
if($change_name_flag){
require "${int_dir}auth_avnewac.pl";
&auth_renew_allaccount("CHANGENAME",$file,$i_handle);
}

# ���_�C���N�g
if($redirect_flag && !$alocal_mode){ &redirect("http://aurasoul.mb2.jp/_auth/?mode=editprof&type=get&pporireki=$in{'pporireki'}&account=$in{'account'}"); }

# �ҏW��A�y�[�W�W�����v
$jump_sec = $auth_jump;
if($in{'email'}){ $jump_sec = 10; }
$jump_url = qq(${file}/#EDIT);
if($aurl_mode){ ($jump_url) = &aurl($jump_url); }

# �w�b�_
&header();

# �����A�h���͂����ꍇ
my($sendcermail_text1);
if($sendcermail_flag){
$sendcermail_text1 = qq(<br><span class="red">���͂��ꂽ���[���A�h���X�ɔF�؃��[���𔭍s���܂����B<br>
���[���{�b�N�X���J���āA�F�؂𑱂��Ă��������B</span>);
}

# �F�؃��[�����s�ł��Ȃ������ꍇ
if($return){
$return = qq(<br>�������A���̗��R�ɂ��F�؃��[���͔��s�ł��܂���ł����B<br>
<span class="red">�c$return</span>);
}


# HTML
print <<"EOM";
<div class="body1">
�ҏW���܂����B
<a href="$jump_url">�}�C�A�J�E���g</a>�ֈړ����܂��B<br>
$sendcermail_text1$after_text1$return
</div>
EOM

# �t�b�^
&footer();

# �����I��
exit;

}

#-----------------------------------------------------------
# �v���r���[�ƃG���[
#-----------------------------------------------------------
sub auth_editprof_error{

# �Ǐ���
my($error) = @_;

# �G���[���A�����b�N
if($lockflag) { &unlock($lockflag); }

# �G���[�\��
if($error){
$error_line .= qq(
<h2 id="ERROR">�G���[</h2>
<div class="error">$error</div>
);
}

$error_line = qq(
<h1>�ҏW�t�H�[��</h1>
$error_line
<h2 id="PREV">�v���r���[</h2>
<div class="prev">$in{'prof'}</div>
$myform
);

# �}�C�t�H�[������荞��
require "${int_dir}auth_myform.pl";
&auth_myform("",$error_line);

# �w�b�_
&header();

# HTML
print qq(
<div class="body1">
$myform
</div>
);

# �t�b�^
&footer();

exit;

}


#-----------------------------------------------------------
# �M�������t�@�C���̍X�V
#-----------------------------------------------------------
sub auth_renew_namefile{

# �Ǐ���
my($file) = @_;
my($line,$flag,$i);

# �t�@�C����`
$file =~ s/[^0-9a-z]//;
if($file eq ""){ return; }

# �t�@�C�����J��
open(NAME_IN,"${int_dir}_id/$file/${file}_name.cgi");
while(<NAME_IN>){
$i++;
if($i > 5){ last; }
chomp;
my($name) = split(/<>/);
if($name eq $in{'name'}){ $flag = 1; }
$line .= qq($name<>\n);
}
close(NAME_IN);

if(!$flag){ $line = qq($in{'name'}<>\n) . $line; }

# �t�@�C������������
open(NAME_OUT,">${int_dir}_id/$file/${file}_name.cgi");
print NAME_OUT $line;
close(NAME_OUT);
chmod($logpms,"${int_dir}_id/$file/${file}_name.cgi");
}

1;
