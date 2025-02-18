#!/bin/bash

# Configuration (customize these)
SENDER_EMAIL="your_email@example.com"
SENDER_PASSWORD="your_smtp_password"  # Or use a more secure method like environment variables
RECIPIENT_EMAIL="recipient@example.com"
SUBJECT="PGP Encrypted Email Test"
SMTP_SERVER="your.smtp.server.com"  # e.g., smtp.gmail.com, smtp.mail.yahoo.com
SMTP_PORT="587" # Or 465 for SMTPS
MESSAGE_FILE="email_message.txt" # File containing the message body
GPG_RECIPIENT_KEY_ID="recipient_key_id" # The recipient's GPG key ID or email address


# 1. Create the email message (or use an existing file)
cat << EOF > "$MESSAGE_FILE"
This is the body of the PGP encrypted email.
You can include any text you want here.
EOF

# 2. Encrypt the message with GPG
gpg --encrypt --recipient "$GPG_RECIPIENT_KEY_ID" "$MESSAGE_FILE" -o "$MESSAGE_FILE.gpg"

# 3. Convert the encrypted message to ASCII Armor (important for email)
gpg --armor "$MESSAGE_FILE.gpg" > "$MESSAGE_FILE.asc"

# 4. Remove the binary encrypted file
rm "$MESSAGE_FILE.gpg"

# 5. Construct the email using `mail` (or `swaks` for more control)

# Using `mail` (simpler, but less control over headers):
# (Requires `mailutils` or `mailx` package to be installed)

# Option 1: Using a here-string for the body (less efficient for large emails)
# mail -s "$SUBJECT" "$RECIPIENT_EMAIL" -a "$MESSAGE_FILE.asc" <<< ""  # Empty body since content is in attachment

#Option 2:  Using a here-document and uuencode (better for larger emails)
(
  echo "Subject: $SUBJECT"
  echo "Content-Type: text/plain; charset=UTF-8" # Important for special characters
  echo "Content-Transfer-Encoding: 7bit" # or quoted-printable if needed
  echo ""  # Blank line separating headers and body
  uuencode "$MESSAGE_FILE.asc" "message.asc" # Attach the ASCII armored file
) | /usr/sbin/sendmail -t "$RECIPIENT_EMAIL"


# Using `swaks` (more complex, but better control, recommended):
# (Requires `swaks` package to be installed)

# swaks --from "$SENDER_EMAIL" --to "$RECIPIENT_EMAIL" --subject "$SUBJECT" \
#     --body-file="$MESSAGE_FILE.asc" \
#     --server "$SMTP_SERVER:$SMTP_PORT" \
#     --auth-user "$SENDER_EMAIL" --auth-pass "$SENDER_PASSWORD" \
#     --tls  # Use TLS encryption (important!)


# 6. Clean up temporary files (optional but good practice)
rm "$MESSAGE_FILE" "$MESSAGE_FILE.asc"

echo "Email sent successfully (hopefully!)"

exit 0
