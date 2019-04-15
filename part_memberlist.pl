
package main;
use Mebius::Export;

#-----------------------------------------------------------
# ���[�h�U�蕪��
#-----------------------------------------------------------

sub bbs_memberlist{
if($in{'type'} eq "vedit"){ &bbs_memberlist_vedit; }
elsif($in{'type'} eq "edit"){ &bbs_memberlist_edit; }
elsif($in{'type'} eq ""){ &bbs_memberlist_view; }
else{ &error("�y�[�W�����݂��܂���B"); }
}

#-----------------------------------------------------------
# �ҏW�t�H�[��
#-----------------------------------------------------------
sub bbs_memberlist_vedit{

# �Ǐ���
my($file,$line);

# ���[�h�ɂ��G���[
if(!$secret_mode){ &error("�y�[�W�����݂��܂���B"); }

# CSS��`
$css_text .= qq(
.blue{color:#00f;}
table,th,tr,td{border-style:none;}
th,td{padding:0.4em;}
input.text{width:12em;}
);

# �^�C�g����`
$sub_title = qq(�����o�[�ݒ�);
$head_link3 = qq(&gt; <a href="member.html">�����o�[���X�g</a>);
$head_link4 = qq(&gt; �����o�[�ݒ�);


# �t�H�[�����擾
my($form) = &bbs_memberlist_getform;

# HTML
my $print = qq(
<h1>�����o�[�ݒ� - $scmy_handle</h1>
$form
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}

#-----------------------------------------------------------
# �t�H�[�����擾
#-----------------------------------------------------------
sub bbs_memberlist_getform{

my($line);

$line .= qq(
<form action="$script" method="post"$sikibetu>
<div>
<input type="hidden" name="mode" value="member">
<input type="hidden" name="moto" value="$realmoto">
<input type="hidden" name="type" value="edit">
<table>
);

#$line .= qq(<tr><td>�M��</td><td><input type="text" name="handle" value="$scmy_handle" class="text"></td><td></td></tr>);
$line .= qq(<tr><td>���[���A�h���X</td><td><input type="text" name="email" value="$scmy_email" class="text">$address</td><td></td></tr>);

if($allowaddress_mode){
my $checked0 = " checked" if(!$scmy_emailkey);
my $checked1 = " checked" if($scmy_emailkey eq "1");
$line .= qq(
<tr><td>�A�h���X���J</td><td>
<input type="radio" name="emailkey" value="1"$checked1> ���J
<input type="radio" name="emailkey" value=""$checked0> ����J
</td>
<td><span class="guide"> �u���J�v��I�Ԃ�<a href="member.html">�����o�[���X�g</a>�ɂ��Ȃ��̃��[���A�h���X���\\������܂�</span></td>
</tr>
);
}


# ���X���m�点���[��
if($allowaddress_mode){
my $checked0 = " checked" if(!$scmy_sendmail);
my $checked1 = " checked" if($scmy_sendmail eq "1");
my $checked2 = " checked" if($scmy_sendmail eq "2");
$line .= qq(
<tr><td>���X���m�点</td><td>
<input type="radio" name="sendmail" value="1"$checked1> �󂯎��(�o�b��)
<input type="radio" name="sendmail" value="2"$checked2> �󂯎��(�g�є�)
<input type="radio" name="sendmail" value=""$checked0> �󂯎��Ȃ�
<td><span class="guide"> �u�󂯎��v��I�ԂƁA�ǂ̋L���Ƀ��X���������ꍇ�ł��A���m�点���[�����͂��܂�</span></td>
</td></tr>
);
}


$line .= qq(
</table>
<br><br>
<input type="submit" value="���̓��e�Őݒ�ύX����">
</div>
</form>
);



$line;

}

#-----------------------------------------------------------
# �ҏW���s
#-----------------------------------------------------------
sub bbs_memberlist_edit{

# �Ǐ���
my($line,$newemail_flag,$flag,$line_address);

# �e��G���[
if(!$postflag){ &error("GET���M�͏o���܂���B"); }
$in{'emailkey'} =~ s/\D//g;
if($in{'emailkey'} > 1){ &error("�ݒ�l���ςł��B"); }
$in{'sendmail'} =~ s/\D//g;
if($in{'sendmail'} > 2){ &error("�ݒ�l���ςł��B"); }
require "${int_dir}regist_allcheck.pl";
($in{'email'}) = &address_check($in{'email'});

&error_view;

# ���b�N�J�n
&lock("MEMBER") if($lockkey);

# �����o�[�t�@�C�����J��
open(MEMBER_IN,"${int_dir}_invite/member_${secret_mode}.cgi");
while(<MEMBER_IN>){
chomp;
my($key,$user,$pass,$handle,$file2,$lasttime,$email,$submittime,$emailkey,$sendmail) = split(/<>/);
if($user eq $username){
$flag = 1;
if($email ne $in{'email'}){ $newemail_flag = 1; }
if(!$submittime){ $submittime = $time; }
($email,$emailkey,$sendmail) = ($in{'email'},$in{'emailkey'},$in{'sendmail'});
}
$line .= qq($key<>$user<>$pass<>$handle<>$file2<>$lasttime<>$email<>$submittime<>$emailkey<>$sendmail<>\n);
}
close(MEMBER_IN);

# �G���[
if(!$flag){ &error("���[�U�[�o�^������܂���B"); }

# ����t�@�C������������
open(MEMBER_OUT,">${int_dir}_invite/member_${secret_mode}.cgi");
print MEMBER_OUT $line;
close(MEMBER_OUT);
Mebius::Chmod(undef,"${int_dir}_invite/member_${secret_mode}.cgi");

# ���[���A�h���X�L�^�t�@�C�����J��
if($newemail_flag){
$line_address .= qq($username<>$in{'email'}<>$in{'handle'}<>\n);
open(ADDRESS_IN,"${int_dir}_invite/address_$adfile.cgi");
while(<ADDRESS_IN>){
chomp;
my($user,$address,$handle) = split(/<>/,$_);
if($user ne $username || $address ne $in{'email'}){ $line_address .= qq($user<>$address<>$handle<>\n); }
}
close(ADDRESS_IN);
}

# ���[���A�h���X�L�^�t�@�C�����X�V
if($newemail_flag){
open(ADDRESS_OUT,">${int_dir}_invite/address_$adfile.cgi");
print ADDRESS_OUT $line_address;
close(ADDRESS_OUT);
Mebius::Chmod(undef,"${int_dir}_invite/address_$adfile.cgi");
}

# ���b�N����
&unlock("MEMBER") if($lockkey);

# ���_�C���N�g
if($alocal_mode){ Mebius::Redirect("","$script?mode=member"); }
else{ Mebius::Redirect("","member.html"); }

}

#-----------------------------------------------------------
# ���݂̃����o�[��\��
#-----------------------------------------------------------
sub bbs_memberlist_view{

# �Ǐ���
my($file,$line);

# ���[�h�ɂ��G���[
if(!$secret_mode){ &error("�y�[�W�����݂��܂���B"); }

# CSS��`
$css_text .= qq(
.blue{color:#00f;}
table,tr,th,td{border-style:none;}
th,td{padding:0.3em 2em 0.3em 0em;}
th{background-color:#dee;}
);

# �Ǘ��҂������o�[��
$line .= qq(<tr><td>$scad_name</td><td><span class="red">�Ǘ���</span></td><td><a href="scmail.html">�Ǘ��҂Ƀ��[��</a></td></tr>\n);

# �����o�[�t�@�C�����J��
open(MEMBER_IN,"${int_dir}_invite/member_${secret_mode}.cgi");
while(<MEMBER_IN>){
chomp;
my($mark);
my($key,$user,$pass,$handle,$file2,$lasttime,$email,$submittime,$emailkey,$sendmail) = split(/<>/);
$line .= qq(<tr>);
if($submittime){ $mark = qq( <span class="red">�Q��</span> ); } else { $mark = qq( <span class="blue">���Ғ�</span> ); }
$line .= qq(<td>$handle</td><td>$mark</td><td>);
if($emailkey eq "1" && $email ne "" && $allowaddress_mode){ $line .= qq(<a href="mailto:$email">$email</a> (������J) );  }
if($user eq $username){ $line .= qq( <a href="$script?mode=member&amp;type=vedit">���ҏW</a>); }
$line .= qq(</td></tr>\n);
}
close(MEMBER_IN);

#<th>�M��</th><th>�Q�����</th><th>���[���A�h���X�i������J�j</th>

# �\�����`
$line = qq(
<table summary="�����o�[���X�g">
$line
</table>
);

# �^�C�g����`
$sub_title = qq(�����o�[���X�g - $title);
$head_link3 = qq(&gt; �����o�[���X�g);


# HTML
my $print = qq(
<h1>�Q�����̃����o�[</h1>
<a href="./">�f���ɖ߂�</a>
<h2>�����o�[���X�g</h2>
$line
);

Mebius::Template::gzip_and_print_all({},$print);

exit;

}


1;
