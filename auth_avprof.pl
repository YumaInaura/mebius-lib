
#-----------------------------------------------------------
# �v���t�B�[���S��������
#-----------------------------------------------------------
sub auth_avprof{

# �Ǐ���
my($i,$kadsense,$max,$print);

# �ݒ�
$max = 40;

# ���[�h�G���[
if($submode3){ &error("���[�h�����݂��܂���B$mode "); }

# �g�єł𔻒�
if($submode1 eq "kview"){
&kget_items("");
$kcanonical = "${auth_url}kview-prof";
}

# �t�@�C���I�[�v��
&open("$in{'account'}");


# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($in{'account'});
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# �v���t�B�[����p�t�@�C������擾
#if($ppprof eq ""){
#open(PROF_IN,"<","${account_directory}${ppfile}_prof.cgi");
#my $top = <PROF_IN>;
#($ppprof) = split(/<>/,$top);
#close(PROF_IN);
#}

# �v���t�B�[����`
foreach(split(/<br>/,$ppprof)){
$i++;
if($i == $max){ $pri_prof .= qq(<a name="AVIEW" id="AVIEW"></a>); }
$_ = &auth_auto_link($_);
$pri_prof .= qq($_<br$xclose>\n);
}

# �g�єł̍L�����`
if($i >= 5 && $kflag){
($kadsense) = &kadsense;
$kadsense = qq($kadsense<hr$xclose>);
}

# ���`
if(!$i){ $i = 0; }

# �^�C�g��
$sub_title = "$ppname - $ppaccount �̃v���t�B�[��";

	# �g�єł̕\��
	if($kflag){
		$print = qq(
		$ppname - $ppfile �̃v���t�B�[��($i�s)
		<hr$xclose>
		$kadsense
		$pri_prof
		);
	}

	# �o�b�ł̕\��
	else{
		$print = qq(
		<h1>$ppname - $ppfile �̃v���t�B�[��($i�s)</h1>
		$pri_prof
		);
	}

Mebius::Template::gzip_and_print_all({},$print);


exit;

}



1;
