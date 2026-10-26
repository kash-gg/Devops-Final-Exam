cd /mnt/d/exam-day/iac || exit 1
ansible localhost -m command -a "cat capstone.env" -c local || exit 1
ansible localhost -m stat -a "path=capstone.env" -c local
