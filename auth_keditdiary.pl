
use Mebius::Auth;
use Mebius::SNS::Crap;
use Mebius::Penalty;

#-----------------------------------------------------------
# SNS ���L�{�̂𑀍�
#-----------------------------------------------------------
sub auth_keditdiary{

# �Ǐ���
my($type);
my($file,$open,$line,$indexline,$pastline,$flag,$top1,$yearfile,$monthfile,$newkey);
my($diary_handler,$diary_index_handler,$penalty_flag,$repair_flag,@renew_diary,%renew_account,%renew);
our($backurl,$backurl_jak_flag);

	# �ύX����L�[�l���`
	# ���b�N����ꍇ
	if($in{'decide'} eq "lock"){ $newkey = "0"; }
	# �폜����ꍇ
	elsif($in{'decide'} eq "delete"){
		$type .= qq( Delete-diary);
	if($myadmin_flag){ $newkey = "4"; } else { $newkey = "2"; }
	}
	elsif($in{'decide'} eq "revive"){
		$type .= qq( Revive-diary);
		$newkey = "1";
	}
	else{ &error("�l�𐳂����w�肵�Ă��������B"); }



# �����`�F�b�N�P
Mebius::Auth::AccountName("Error-view",$in{'account'});
$file = $in{'account'};

# �����`�F�b�N�P
$open = $in{'num'};
$open =~ s/\D//g;
	if($open eq ""){ &error("�l�𐳂����w�肵�Ă��������B"); }

	# ���O�C�����Ă��Ȃ��ꍇ
	if(!$idcheck){ &error("���L���폜����ɂ́A���O�C�����Ă��������B"); }

	# �{�l�ł��Ǘ��҂ł��Ȃ��ꍇ
	if(!$myadmin_flag && $file ne $pmfile){ &error("���L�͖{�l�����폜�ł��܂���B"); }

	# �v���t�B�[�����J��
	my(%account) = Mebius::Auth::File("Get-hash Option File-check-error",$file);

	# �v���r���[�̏ꍇ
	if($in{'preview'} eq "on"){ &auth_keditdiary_preview("",$file,$open); }

# ���b�N�J�n
&lock("auth$file") if $lockkey;

# ���L�P�̃t�@�C�����J��
my($diary) = Mebius::Auth::diary("File-check-error",$file,$open);

	# �폜�ς݂̏ꍇ�A�Ǘ��҈ȊO�͕ύX�ł��Ȃ��悤��
	if( ($diary->{'key'} eq "4" || $diary->{'key'} eq "2") && !$myadmin_flag){
		Mebius::AccessLog(undef,"Account-diary-delete-missed");
		&error("���s�ł��܂���ł����B");
	}
	else{
		Mebius::AccessLog(undef,"Account-diary-delete-successed");
	}

# �����p���H����
$yearfile = $diary->{'year'};
$monthfile = $diary->{'month'};

# �X�V����
$renew{'key'} = $newkey;
$renew{'control_datas'} = qq($pmfile=$pmname=$date);
$renew{'concept'} = $diary->{'concept'};

	# �y�i���e�B�ƕ��������t���O�𗧂Ă�
	# �폜����ꍇ
	if($myadmin_flag && $in{'decide'} eq "delete" && $in{'penalty'}){
		$penalty_flag = 1;
		$renew{'concept'} .= qq( Penalty-done);
	}
	# ��������ꍇ
	if($myadmin_flag && $in{'decide'} eq "revive" && $diary->{'concept'} =~ /Penalty-done/){
		$renew{'concept'} =~ s/Penalty-done//g;
		$repair_flag = 1;
	}

# ���L���X�V
Mebius::Auth::diary("Renew",$file,$open,\%renew);

	# �Ǘ��ҍ폜�̏ꍇ�A�y�i���e�B�𐶐�
	if($penalty_flag){

		# ��ʃy�i���e�B
		Mebius::Authpenalty("Penalty",$file,$diary->{'comment'},"SNS�̓��L - $diary->{'subject'}","${auth_url}$file/d-$open");

		# SNS�y�i���e�B
		Mebius::AuthPenaltyOption("Penalty",$file,3*24*60*60);

	}

	# �Ǘ��ҕ����̏ꍇ�A�y�i���e�B������
	if($repair_flag){

		# ��ʃy�i���e�B
		Mebius::Authpenalty("Repair",$file);

		# SNS�y�i���e�B
		Mebius::AuthPenaltyOption("Penalty",$file,-3*24*60*60);

	}

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ���s�C���f�b�N�X���J��
open($diary_index_handler,"<","${account_directory}diary/${file}_diary_index.cgi");
flock($diary_index_handler,1);
my $nowtop1 = <$diary_index_handler>;
$indexline .= $nowtop1;

	# �t�@�C����W�J
	while(<$diary_index_handler>){
		chomp $_;
		my($key,$num,$sub,$res,$dates,$newtime) = split(/<>/,$_);
			if($open eq $num){
				$key = $newkey;
				$indexline .= qq($key<>$num<>$sub<>$res<>$dates<>$newtime<>\n);
				my($year,$month,$day,$hour,$min,$sec) = split(/,/,$dates);
			}
			else{ $indexline .= qq($_\n); }
	}
close($diary_index_handler);

# ���s�C���f�b�N�X�������o��
Mebius::Fileout("","${account_directory}diary/${file}_diary_index.cgi",$indexline);

# �����`�F�b�N�R
$yearfile =~ s/\D//g;
$monthfile =~ s/\D//g;

	# �q�b�g�����ꍇ�̂݁A���ʃC���f�b�N�X���J��
	if($yearfile ne "" && $monthfile ne ""){
		open($month_index_handler,"<${account_directory}diary/${file}_diary_${yearfile}_${monthfile}.cgi");
		flock($month_index_handler,1);
			while(<$month_index_handler>){
				chomp $_;
				my($key,$num,$sub,$res,$dates) = split(/<>/,$_);
				if($open eq $num){
				$key = $newkey;
				$pastline .= qq($key<>$num<>$sub<>$res<>$dates<>\n);
				}
				else{ $pastline .= qq($_\n); }
			}
		close($month_index_handler);
	}

	# �q�b�g�����ꍇ�̂݁A���ʃC���f�b�N�X�������o��
	if($yearfile ne "" && $monthfile ne ""){
		Mebius::Fileout("","${account_directory}diary/${file}_diary_${yearfile}_${monthfile}.cgi",$pastline);
	}

	# �S�����o�[�̐V���ꗗ����폜
	if($type =~ /Delete-diary/){
		Mebius::Auth::all_members_diary("Delete-diary New-file Renew",$file,$open);
		Mebius::Auth::all_members_diary("Delete-diary Alert-file Renew",$file,$open);
	}

	# �S�����o�[�̐V���ꗗ���畜��
	elsif($type =~ /Revive-diary/){
		Mebius::Auth::all_members_diary("Revive-diary New-file Renew",$file,$open);
		Mebius::Auth::all_members_diary("Revive-diary Alert-file Renew",$file,$open);
	}

	# �l�����~�}�C���r�V�����L�̃C���f�b�N�X����폜
	if($type =~ /Delete-diary/){
		Mebius::Auth::FriendIndex("Delete-diary",$account{'file'},$open);
	}

	# �����ˁI�����L���O����폜
	if($type =~ /Delete-diary/){
		my(%time) = Mebius::Getdate("Get-hash",$diary->{'posttime'});
		Mebius::Auth::CrapRankingDay("Delete-diary Renew",$time{'yearf'},$time{'monthf'},$time{'dayf'},undef,$account{'file'},$open);
	}

# ���b�N����
&unlock("auth$file") if $lockkey;

	# ���_�C���N�g�i�Ǘ����[�h�֖߂�j
	if($backurl_jak_flag && $myadmin_flag){
		Mebius::Redirect("","$backurl&jump=newres");
	}
	# ���_�C���N�g�i�v���t�B�[���֖߂�j
	else{
		Mebius::Redirect("","$auth_url${file}/#DIARY");
	}

# �I��
exit;

}



#-----------------------------------------------------------
# �폜�O�̃v���r���[���
#-----------------------------------------------------------

sub auth_keditdiary_preview{

my($type,$file,$open) = @_;
my($link,$adlink1);

# �w�b�_
&header();

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($file);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

# ���L�P�̃t�@�C�����J��
open(DIARY_IN,"${account_directory}diary/${file}_diary_${open}.cgi") || &error("���L���J���܂���B");
my $top1 = <DIARY_IN>;
my($key,$num,$sub,$res,$dates,$newtime,$restime) = split(/<>/,$top1);
close(DIARY_IN);


$link = "$file/d-$open";
if($aurl_mode){ ($link) = &aurl($link); }

if($myadmin_flag){ $adlink1 = qq( / <a href="$script?mode=keditdiary&amp;account=$file&amp;num=$open&amp;decide=delete&amp;penalty=1">���폜�����s����i�y�i���e�B����j</a>�i�����s�j); }

# HTML
print <<"EOM";
<div class="body1">
$footer_link<hr><br>
���L�i<a href="$link">$sub</a>�j���폜���܂����A��낵���ł����H<br>
��x�폜����ƁA���̓��L���̑S�R�����g�������Ȃ��Ȃ�܂��B<br><br>

<a href="$script?mode=keditdiary&amp;account=$file&amp;num=$open&amp;decide=delete">���폜�����s����</a>�i�����s�j
$adlink1
<br><br><hr>
$footer_link2
</div>
EOM

# �t�b�^
&footer();

# �I��
exit;

}






1;
