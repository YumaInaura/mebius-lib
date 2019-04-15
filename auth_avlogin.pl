
package main;

#-------------------------------------------------
# �v���t�B�[���\��
#-------------------------------------------------
sub auth_avlogin{

# �Ǐ���
my($file,$acbk_line,$first_line,$rlogin_line,$domain_links);
my($my_account) = Mebius::my_account();
our($server_domain);


#�����`�F�b�N
$file = $submode3;
$file =~ s/[^0-9a-z]//g;

# CSS��`
$css_text .= qq(
table.login_history{width:100%;}
);

# �t�@�C�����J��
&open($file);


	# �Ǘ��҂ł��������g�ł��Ȃ��ꍇ
	if(!$my_account->{'admin_flag'} && $my_account->{'id'} ne $file){ &error("�����̏��ȊO�͉{���ł��܂���B","401"); }

# �����O�C������
($rlogin_line,$first_line) = &auth_get_loginhistory("",$file);

# �M��
my($line_names) = &auth_get_namehistory("",$file);

# �V���O�C������
my($index_line) = shift_jis(Mebius::Login->login_history("Index",$file,$my_account->{'id'}));

# �^�C�g������
$sub_title = "���O�C������ - $title";
$head_link3 = qq(&gt; ���O�C������ - $title);

# �i�r
my $link2 = "${auth_url}${ppfile}/";
if($aurl_mode){ ($link2) = &aurl($link2); }
my $navilink .= qq(<a href="$link2">���̃����o�[�̃A�J�E���g�֖߂�</a>);

# HTML
my $print = <<"EOM";
$footer_link
<h1>�e�헚���F $ppname - $ppaccount</h1>
$navilink
$domain_links
<h2>�A�N�Z�X����</h2>
$index_line
$first_line
$line_names
$rlogin_line
$footer_link2
EOM

Mebius::Template::gzip_and_print_all({},$print);

# �����I��
exit;

}

#-----------------------------------------------------------
# �e��f�[�^�擾
#-----------------------------------------------------------

sub auth_get_loginhistory{

# �Ǐ���
my($type,$file) = @_;
my($top);

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �����f�[�^���J��
open(FIRST_IN,"<","${account_directory}${ppaccount}_first.cgi");
my $top = <FIRST_IN>;
my($time2,$date2,$xip2,$host2,$age2,$cnumber2,$put_pass2) = split(/<>/,$top);
close(FIRST_IN);

$first_line .= qq(�o�^���F $date2 );

	# �Ǘ��҂����ɕ\��
	if($myadmin_flag >= 1){
		$first_line .= qq(�Ǘ��ԍ��F ) . Mebius::Admin::user_control_link_cookie($cnumber2);
		$first_line .= qq( AGENT: ) . Mebius::Admin::user_control_link_user_agent($age2);
	}

	# �}�X�^�[�����ɕ\��
	if($myadmin_flag >= 5){
		$first_line .= qq( - HOST:  ) . Mebius::Admin::user_control_link_host($host2) . qq( - XIP: $xip2 - PASS: $put_pass2);
	}

	# ���������ɕ\��
	if($file eq $pmfile && $myadmin_flag < 5){
		$first_line .= qq( ���[�U�[�G�[�W�F���g�F $age2 );
	}

$first_line = qq(<h2>�����f�[�^</h2><ul>$first_line</ul>);


# �X�V���f�[�^���J��
open(ACBK_IN,"<","${account_directory}${ppaccount}_acbk.cgi");
my $top2 = <ACBK_IN>;
my($none,$none,$acpass) = split(/<>/,$top2);
close(ACBK_IN);
if($myadmin_flag >= 5 && $acpass){ $acbk_line = qq(<h2>�X�V�O�f�[�^</h2>PASS: $acpass); }

# �Ǘ��҂łȂ��ꍇ
if(!$myadmin_flag){ return("",$first_line); }

# �h���h���O�C���������J��
open(RLOGIN_IN,"<","${account_directory}${ppaccount}_rlogin.cgi");
	while(<RLOGIN_IN>){
		chomp;
		my($lasttime,$xip2,$host2,$number,$id) = split(/<>/);

		my($login_date) = Mebius::Getdate("",$lasttime);
		$xip2 =~ tr/+/ /;
		$xip2 =~ s/%([a-fA-F0-9][a-fA-F0-9])/pack("H2", $1)/eg;
		$rlogin_line .= qq(<li>);
		$rlogin_line .= qq(���O�C�����ԁF $login_date ( $lasttime ) - �Ǘ��ԍ��F );
		$rlogin_line .= Mebius::Admin::user_control_link_cookie($number);
		$rlogin_line .= qq( - ID: $id );
			if($myadmin_flag >= 5){
				$rlogin_line .= qq(- XIP: $xip2 - HOST: );
				$rlogin_line .= Mebius::Admin::user_control_link_host($host2);
			}
	}
close(RLOGIN_IN);
$rlogin_line = qq(<h2>���O�C������(��)</h2><ul>$rlogin_line</ul>);

return($rlogin_line,$first_line);


}

#-----------------------------------------------------------
# �M���������擾
#-----------------------------------------------------------
sub auth_get_namehistory{

# �Ǐ���
my($type,$file) = @_;
my($i,$line);

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �t�@�C�����J��
open(NAME_IN,"<","${account_directory}${file}_name.cgi");
while(<NAME_IN>){
chomp;
$i++;
#if($i >= 2){ $line .= qq( - ); }
my($name) = split(/<>/);
$line .= qq(<li>$name\n);
}
close(NAME_IN);

$line = qq(<h2>�M������</h2><ul>$line</ul>);

return($line);

}



1;
