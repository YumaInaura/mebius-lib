
package main;
use strict;

#-------------------------------------------------
# �}�C���r�󋵂��`�F�b�N
#-------------------------------------------------
sub do_auth_checkfriend{

# �Ǐ���
my($account,$deny) = @_;
my($top,$yetfriend_flag);
our($yetfriend,$denyfriend,$myadmin_flag);

# �����̃A�J�E���g���擾
my($my_account) = Mebius::my_account();

	# �A�J�E���g������
	if(Mebius::Auth::AccountName(undef,$account)){ return(); }

# �f�B���N�g����`
my($account_directory) = Mebius::Auth::account_directory($account);
	if(!$account_directory){ die("Perl Die! Account directory setting is empty."); }

	# ���O�C�����̂ݏ������s
	if($my_account->{'file'}){

		# �A�J�E���g������
		if(Mebius::Auth::AccountName(undef,$my_account->{'file'})){ return(); }

		# �}�C���r�o�^�ς݂̏ꍇ�A�t���O�𗧂Ă�
		open(SFRIEND_IN,"<","${account_directory}friend/$my_account->{'file'}_f.cgi"); # $pmfile �͊ԈႢ�ł͂Ȃ��͂�
		$top = <SFRIEND_IN>;
		my($key) = split(/<>/,$top);
		if($key eq "1"){ $yetfriend = $yetfriend_flag = 1; }
		elsif($key eq "0" && !$myadmin_flag){ $denyfriend = 1; }
		close(SFRIEND_IN);
	}

return($yetfriend_flag);

}

1;
