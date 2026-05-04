#!/bin/bash
# grade.sh — Display all student solution submissions for review
#
# Prints each student's answer.txt, preceded by their username and status.
# Provides a submitted/not-submitted summary at the end.
#
# Usage:
#   sudo bash setup/grade.sh [OPTIONS] [students.csv]
#
# Options:
#   -c, --condensed         Show condensed one-line-per-student summary
#   -o, --output <file>     Write results to a CSV file
#
# Without a CSV, falls back to all members of the 'students' group:
#   sudo bash setup/grade.sh

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root." >&2
    exit 1
fi

CONDENSED=false
CSV_OUTPUT=""
CSV_FILE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--condensed)
            CONDENSED=true
            shift
            ;;
        -o|--output)
            if [[ -z "${2:-}" ]]; then
                echo "ERROR: --output requires a file path argument." >&2
                exit 1
            fi
            CSV_OUTPUT="$2"
            shift 2
            ;;
        -*)
            echo "ERROR: Unknown option: $1" >&2
            exit 1
            ;;
        *)
            CSV_FILE="$1"
            shift
            ;;
    esac
done

STUDENTS_GROUP="students"
DIVIDER="============================================================"
SUBDIV="------------------------------------------------------------"

# Associative array: username -> "First Last"
declare -A STUDENT_NAMES

# Load names from CSV if available
if [ -n "$CSV_FILE" ] && [ -f "$CSV_FILE" ]; then
    line_num=0
    while IFS=',' read -r u_username u_password u_first u_last u_rest; do
        line_num=$((line_num + 1))
        [ "$line_num" -eq 1 ] && [ "$u_username" = "username" ] && continue
        [ -z "$u_username" ] && continue
        u_username=$(echo "$u_username" | tr -d '[:space:]')
        u_first=$(echo "$u_first" | tr -d '[:space:]')
        u_last=$(echo "$u_last" | tr -d '[:space:]')
        STUDENT_NAMES["$u_username"]="$u_first $u_last"
    done < "$CSV_FILE"
fi

# Initialize CSV output file with header
if [ -n "$CSV_OUTPUT" ]; then
    echo "username,first_name,last_name,submitted,has_content" > "$CSV_OUTPUT"
fi

# Returns true if the file exists and has meaningful content (>10 bytes)
file_has_content() {
    local f="$1"
    [ -f "$f" ] && [ "$(wc -c < "$f")" -gt 10 ]
}

submitted=0
not_submitted=0

grade_student() {
    local username="$1"
    local solution_file="/home/$username/solution/answer.txt"
    local display_name="${STUDENT_NAMES[$username]:-}"

    # Determine status and content labels
    local submitted_val content_val
    if [ -f "$solution_file" ]; then
        submitted_val="yes"
        if file_has_content "$solution_file"; then
            content_val="yes"
        else
            content_val="no"
        fi
    else
        submitted_val="no"
        content_val="no"
    fi

    if $CONDENSED; then
        local status_label content_label
        if [ "$submitted_val" = "yes" ]; then
            status_label="SUBMITTED"
        else
            status_label="NOT SUBMITTED"
        fi
        if [ "$submitted_val" = "yes" ] && [ "$content_val" = "yes" ]; then
            content_label="yes"
        elif [ "$submitted_val" = "yes" ]; then
            content_label="no (empty/trivial)"
        else
            content_label="—"
        fi
        printf "  %-20s %-26s %-15s %s\n" "$username" "${display_name:-—}" "$status_label" "$content_label"
    else
        echo "$SUBDIV"
        printf "  Student : %s\n" "$username"
        [ -n "$display_name" ] && printf "  Name    : %s\n" "$display_name"

        if [ "$submitted_val" = "yes" ]; then
            printf "  Status  : [SUBMITTED]\n"
            echo ""
            sed 's/^/    /' "$solution_file"
        else
            printf "  Status  : [NOT SUBMITTED]\n"
            if [ -d "/home/$username/solution" ]; then
                echo "  Note    : solution/ directory exists but answer.txt is missing"
            fi
        fi
        echo ""
    fi

    # Append to CSV output file
    if [ -n "$CSV_OUTPUT" ]; then
        local first_name="" last_name=""
        if [ -n "$display_name" ]; then
            first_name="${display_name%% *}"
            last_name="${display_name#* }"
        fi
        echo "$username,$first_name,$last_name,$submitted_val,$content_val" >> "$CSV_OUTPUT"
    fi
}

# Print report header
echo "$DIVIDER"
if $CONDENSED; then
    echo "  MASON HIGH SCHOOL — COMET MYSTERY GRADING REPORT (CONDENSED)"
else
    echo "  MASON HIGH SCHOOL — COMET MYSTERY GRADING REPORT"
fi
printf "  Generated: %s\n" "$(date)"
echo "$DIVIDER"
echo ""

if $CONDENSED; then
    printf "  %-20s %-26s %-15s %s\n" "USERNAME" "FULL NAME" "STATUS" "HAS CONTENT"
    printf "  %-20s %-26s %-15s %s\n" "--------" "---------" "------" "-----------"
fi

if [ -n "$CSV_FILE" ] && [ -f "$CSV_FILE" ]; then
    line_num=0
    while IFS=',' read -r username rest; do
        line_num=$((line_num + 1))
        [ "$line_num" -eq 1 ] && [ "$username" = "username" ] && continue
        [ -z "$username" ] && continue
        username=$(echo "$username" | tr -d '[:space:]')
        if ! id "$username" &>/dev/null; then
            continue
        fi
        grade_student "$username"
        if [ -f "/home/$username/solution/answer.txt" ]; then
            submitted=$((submitted + 1))
        else
            not_submitted=$((not_submitted + 1))
        fi
    done < "$CSV_FILE"

else
    if ! $CONDENSED; then
        echo "  (No CSV provided — checking all members of group '$STUDENTS_GROUP')"
        echo ""
    fi

    if ! getent group "$STUDENTS_GROUP" > /dev/null 2>&1; then
        echo "ERROR: Group '$STUDENTS_GROUP' not found. Pass a CSV file instead." >&2
        exit 1
    fi

    mapfile -t student_list < <(
        getent group "$STUDENTS_GROUP" \
        | cut -d: -f4 \
        | tr ',' '\n' \
        | sort \
        | grep -v '^$'
    )

    for username in "${student_list[@]}"; do
        grade_student "$username"
        if [ -f "/home/$username/solution/answer.txt" ]; then
            submitted=$((submitted + 1))
        else
            not_submitted=$((not_submitted + 1))
        fi
    done
fi

total=$((submitted + not_submitted))

echo ""
echo "$DIVIDER"
echo "  SUMMARY"
printf "  Submitted     : %d / %d\n" "$submitted" "$total"
printf "  Not submitted : %d / %d\n" "$not_submitted" "$total"
echo "$DIVIDER"

if [ -n "$CSV_OUTPUT" ]; then
    printf "\n  Results written to: %s\n" "$CSV_OUTPUT"
fi
