const express = require('express');
const mongoose = require('mongoose');
const bcrypt = require('bcrypt');
const nodemailer = require('nodemailer');
const cors = require('cors');
const multer = require('multer');
const { parse } = require('csv-parse');
const fs = require('fs');
const schedule = require('node-schedule');
require('dotenv').config();

const app = express();

// Enable CORS for all origins (development only)
app.use(cors());
app.use(express.json());

// Configure Multer for file uploads
const upload = multer({ dest: 'uploads/' });

// MongoDB Atlas Connection
mongoose.connect(process.env.MONGODB_URI)
  .then(() => console.log('Connected to MongoDB Atlas'))
  .catch((err) => console.error('MongoDB connection failed:', err));

// Schemas
const adminSchema = new mongoose.Schema({
  username: String,
  password: String,
});
const studentSchema = new mongoose.Schema({
  username: String,
  password: String,
  name: String,
  rollNo: String,
  konguEmail: String,
  linkedin: String,
  phone: String,
  personalEmail: String,
  department: String,
  joiningYear: String,
  passingYear: String,
});
const alumniSchema = new mongoose.Schema({
  username: String,
  password: String,
  name: String,
  rollNo: String,
  email: String,
  department: String,
  passedOutYear: String,
  company: String,
  linkedin: String,
  phone: String,
  otherEmail: String,
  address: String,
});
const pendingAlumniSchema = new mongoose.Schema({
  name: String,
  rollNo: String,
  email: String,
  department: String,
  passedOutYear: String,
});

const Admin = mongoose.model('Admin', adminSchema);
const Student = mongoose.model('Student', studentSchema);
const Alumni = mongoose.model('Alumni', alumniSchema);
const PendingAlumni = mongoose.model('PendingAlumni', pendingAlumniSchema);

// Initialize Admin User
async function initializeAdmin() {
  try {
    const adminExists = await Admin.findOne({ username: 'sujith' });
    if (!adminExists) {
      const hashedPassword = await bcrypt.hash('SujithAdmin', 10);
      await Admin.create({ username: 'sujith', password: hashedPassword });
      console.log('Admin user created: sujith/SujithAdmin');
    } else {
      console.log('Admin user already exists');
    }
  } catch (err) {
    console.error('Error initializing admin:', err);
  }
}

// Nodemailer Setup
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASS,
  },
});

// Generate Random Password
function generatePassword() {
  return Math.random().toString(36).slice(-8);
}

// Send Email with Fallback
async function sendEmail(options) {
  try {
    await transporter.sendMail(options);
    console.log(`Email sent to ${options.to}`);
    return { success: true };
  } catch (err) {
    console.error(`Email sending error to ${options.to}:`, err.message, err.stack);
    return { success: false, error: err.message };
  }
}

// Schedule Student-to-Alumni Transition (runs every January 1st)
schedule.scheduleJob('0 0 1 1 *', async () => {
  try {
    const currentYear = new Date().getFullYear().toString();
    console.log(`Checking students for alumni transition in ${currentYear}`);
    const students = await Student.find({ passingYear: currentYear });
    
    for (const student of students) {
      const alumni = new Alumni({
        username: student.konguEmail,
        password: student.password,
        name: student.name,
        rollNo: student.rollNo,
        email: student.konguEmail,
        department: student.department,
        passedOutYear: student.passingYear,
        linkedin: student.linkedin,
        phone: student.phone,
        otherEmail: student.personalEmail,
      });

      await alumni.save();
      await Student.deleteOne({ username: student.username });

      // Send Email
      const emailResult = await sendEmail({
        from: process.env.EMAIL_USER,
        to: student.konguEmail,
        subject: 'AlumniConnect: Moved to Alumni',
        text: `You have been moved to the Alumni database.\nUsername: ${student.konguEmail}\nPassword: Your existing password`,
      });

      if (!emailResult.success) {
        console.warn(`Student moved to alumni but email failed for ${student.konguEmail}: ${emailResult.error}`);
      }
    }
    console.log(`Moved ${students.length} students to alumni`);
  } catch (err) {
    console.error('Alumni transition error:', err.message, err.stack);
  }
});

// Login Endpoint
app.post('/api/login', async (req, res) => {
  try {
    const { username, password, role } = req.body;
    if (!username || !password || !role) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    let user;
    if (role === 'admin') {
      user = await Admin.findOne({ username });
    } else if (role === 'student') {
      if (!username.match(/^[\w]+\.\d{2}[a-zA-Z]+@kongu\.edu$/)) {
        return res.status(400).json({ message: 'Invalid Kongu email format' });
      }
      user = await Student.findOne({ username });
    } else if (role === 'alumni') {
      user = await Alumni.findOne({ username });
    } else {
      return res.status(400).json({ message: 'Invalid role' });
    }

    if (!user) {
      return res.status(400).json({ message: 'User not found' });
    }

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(400).json({ message: 'Invalid credentials' });
    }

    res.status(200).json({ message: 'Login successful', user });
  } catch (err) {
    console.error('Login error:', err.message, err.stack);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Admin Add Student
app.post('/api/admin/add_student', async (req, res) => {
  try {
    const { name, rollNo, konguEmail } = req.body;
    if (!name || !rollNo || !konguEmail) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const emailRegex = /^[\w]+\.\d{2}[a-zA-Z]+@kongu\.edu$/;
    if (!emailRegex.test(konguEmail)) {
      return res.status(400).json({ message: 'Invalid Kongu email format' });
    }

    const match = konguEmail.match(/\.(\d{2})([a-zA-Z]+)@/);
    if (!match) {
      return res.status(400).json({ message: 'Unable to parse department and year from email' });
    }

    const password = generatePassword();
    const hashedPassword = await bcrypt.hash(password, 10);

    const student = new Student({
      username: konguEmail,
      password: hashedPassword,
      name,
      rollNo,
      konguEmail,
      department: match[2].toUpperCase(),
      joiningYear: `20${match[1]}`,
    });

    await student.save();

    // Send Email
    const emailResult = await sendEmail({
      from: process.env.EMAIL_USER,
      to: konguEmail,
      subject: 'AlumniConnect Student Account',
      text: `Your username: ${konguEmail}\nYour password: ${password}`,
    });

    if (!emailResult.success) {
      console.warn(`Student added but email failed for ${konguEmail}: ${emailResult.error}`);
    }

    res.status(200).json({ 
      message: 'Student added successfully', 
      emailStatus: emailResult.success ? 'Email sent' : 'Email failed'
    });
  } catch (err) {
    console.error('Add student error:', err.message, err.stack);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Admin Add Alumni
app.post('/api/admin/add_alumni', async (req, res) => {
  try {
    const { name, rollNo, email, department, passedOutYear } = req.body;
    if (!name || !rollNo || !email || !department || !passedOutYear) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const username = email.split('@')[0];
    const password = generatePassword();
    const hashedPassword = await bcrypt.hash(password, 10);

    const alumni = new Alumni({
      username,
      password: hashedPassword,
      name,
      rollNo,
      email,
      department,
      passedOutYear,
    });

    await alumni.save();

    // Send Email
    const emailResult = await sendEmail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'AlumniConnect Alumni Account',
      text: `Your username: ${username}\nYour password: ${password}`,
    });

    if (!emailResult.success) {
      console.warn(`Alumni added but email failed for ${email}: ${emailResult.error}`);
    }

    res.status(200).json({ 
      message: 'Alumni added successfully',
      emailStatus: emailResult.success ? 'Emailsent' : 'Email failed'
    });
  } catch (err) {
    console.error('Add alumni error:', err.message, err.stack);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Admin Bulk Add Students via CSV
app.post('/api/admin/bulk_add_students', upload.single('file'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ message: 'No file uploaded' });
    }

    const students = [];
    fs.createReadStream(req.file.path)
      .pipe(parse({ columns: true, trim: true }))
      .on('data', (row) => {
        if (row.name && row.rollNo && row.konguEmail) {
          students.push(row);
        }
      })
      .on('end', async () => {
        const results = [];
        for (const student of students) {
          try {
            const emailRegex = /^[\w]+\.\d{2}[a-zA-Z]+@kongu\.edu$/;
            if (!emailRegex.test(student.konguEmail)) {
              results.push({ email: student.konguEmail, status: 'Invalid email format' });
              continue;
            }

            const match = student.konguEmail.match(/\.(\d{2})([a-zA-Z]+)@/);
            if (!match) {
              results.push({ email: student.konguEmail, status: 'Unable to parse department and year' });
              continue;
            }

            const password = generatePassword();
            const hashedPassword = await bcrypt.hash(password, 10);

            const newStudent = new Student({
              username: student.konguEmail,
              password: hashedPassword,
              name: student.name,
              rollNo: student.rollNo,
              konguEmail: student.konguEmail,
              department: match[2].toUpperCase(),
              joiningYear: `20${match[1]}`,
            });

            await newStudent.save();

            // Send Email
            const emailResult = await sendEmail({
              from: process.env.EMAIL_USER,
              to: student.konguEmail,
              subject: 'AlumniConnect Student Account',
              text: `Your username: ${student.konguEmail}\nYour password: ${password}`,
            });

            results.push({ 
              email: student.konguEmail, 
              status: emailResult.success ? 'Added successfully' : `Added but email failed: ${emailResult.error}`
            });
          } catch (err) {
            results.push({ email: student.konguEmail, status: `Error: ${err.message}` });
          }
        }

        // Clean up uploaded file
        fs.unlinkSync(req.file.path);

        res.status(200).json({ message: 'Bulk add completed', results });
      })
      .on('error', (err) => {
        console.error('CSV parsing error:', err.message, err.stack);
        res.status(500).json({ message: `CSV parsing error: ${err.message}` });
      });
  } catch (err) {
    console.error('Bulk add students error:', err.message, err.stack);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Admin Approve Alumni
app.post('/api/admin/approve_alumni', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }

    const pendingAlumni = await PendingAlumni.findOne({ email });
    if (!pendingAlumni) {
      return res.status(400).json({ message: 'Pending alumni not found' });
    }

    const username = pendingAlumni.email.split('@')[0];
    const password = generatePassword();
    const hashedPassword = await bcrypt.hash(password, 10);

    const alumni = new Alumni({
      username,
      password: hashedPassword,
      name: pendingAlumni.name,
      rollNo: pendingAlumni.rollNo,
      email: pendingAlumni.email,
      department: pendingAlumni.department,
      passedOutYear: pendingAlumni.passedOutYear,
    });

    await alumni.save();
    await PendingAlumni.deleteOne({ email });

    // Send Email
    const emailResult = await sendEmail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'AlumniConnect Approval',
      text: `Congratulations! You're part of Kongu Alumni.\nUsername: ${username}\nPassword: ${password}`,
    });

    if (!emailResult.success) {
      console.warn(`Alumni approved but email failed for ${email}: ${emailResult.error}`);
    }

    res.status(200).json({ 
      message: 'Alumni approved',
      emailStatus: emailResult.success ? 'Email sent' : 'Email failed'
    });
  } catch (err) {
    console.error('Approve alumni error:', err.message, err.stack);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Admin Reject Alumni
app.post('/api/admin/reject_alumni', async (req, res) => {
  try {
    const { email } = req.body;
    if (!email) {
      return res.status(400).json({ message: 'Email is required' });
    }

    const pendingAlumni = await PendingAlumni.findOne({ email });
    if (!pendingAlumni) {
      return res.status(400).json({ message: 'Pending alumni not found' });
    }

    await PendingAlumni.deleteOne({ email });

    // Send Email
    const emailResult = await sendEmail({
      from: process.env.EMAIL_USER,
      to: email,
      subject: 'AlumniConnect Signup Rejected',
      text: `Dear ${pendingAlumni.name},\nYour alumni signup request has been rejected. Please contact the admin for more details.`,
    });

    if (!emailResult.success) {
      console.warn(`Alumni rejected but email failed for ${email}: ${emailResult.error}`);
    }

    res.status(200).json({ 
      message: 'Alumni request rejected',
      emailStatus: emailResult.success ? 'Email sent' : 'Email failed'
    });
  } catch (err) {
    console.error('Reject alumni error:', err.message, err.stack);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Get Pending Alumni
app.get('/api/admin/pending_alumni', async (req, res) => {
  try {
    const pendingAlumni = await PendingAlumni.find();
    res.status(200).json(pendingAlumni);
  } catch (err) {
    console.error('Get pending alumni error:', err.message, err.stack);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Student Update
app.post('/api/student/update', async (req, res) => {
  try {
    const { username, linkedin, phone, personalEmail, department, joiningYear, passingYear } = req.body;
    if (!username) {
      return res.status(400).json({ message: 'Username is required' });
    }

    await Student.updateOne(
      { username },
      { linkedin, phone, personalEmail, department, joiningYear, passingYear }
    );
    res.status(200).json({ message: 'Details updated' });
  } catch (err) {
    console.error('Student update error:', err.message, err.stack);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Alumni Update
app.post('/api/admin/alumni/update', async (req, res) => {
  try {
    const { username, company, linkedin, phone, otherEmail, address } = req.body;
    if (!username) {
      return res.status(400).json({ message: 'Username is required' });
    }

    await Alumni.updateOne(
      { username },
      { company, linkedin, phone, otherEmail, address }
    );
    res.status(200).json({ message: 'Details updated' });
  } catch (err) {
    console.error('Alumni update error:', err.message, err.stack);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Change Password
app.post('/api/change_password', async (req, res) => {
  try {
    const { username, newPassword } = req.body;
    if (!username || !newPassword) {
      return res.status(400).json({ message: 'Username and new password are required' });
    }

    const hashedPassword = await bcrypt.hash(newPassword, 10);
    const updated = await Student.updateOne({ username }, { password: hashedPassword }) ||
                    await Alumni.updateOne({ username }, { password: hashedPassword });
    if (updated.matchedCount === 0) {
      return res.status(400).json({ message: 'User not found' });
    }
    res.status(200).json({ message: 'Password changed' });
  } catch (err) {
    console.error('Change password error:', err.message, err.stack);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Alumni Signup
app.post('/api/alumni/signup', async (req, res) => {
  try {
    const { name, rollNo, email, department, passedOutYear } = req.body;
    if (!name || !rollNo || !email || !department || !passedOutYear) {
      return res.status(400).json({ message: 'Missing required fields' });
    }

    const pendingAlumni = new PendingAlumni({
      name,
      rollNo,
      email,
      department,
      passedOutYear,
    });

    await pendingAlumni.save();
    res.status(200).json({ message: 'Signup request sent' });
  } catch (err) {
    console.error('Alumni signup error:', err.message, err.stack);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Manual Trigger for Alumni Transition (for testing)
app.post('/api/check_alumni_transition', async (req, res) => {
  try {
    const currentYear = new Date().getFullYear().toString();
    const students = await Student.find({ passingYear: currentYear });
    
    for (const student of students) {
      const alumni = new Alumni({
        username: student.konguEmail,
        password: student.password,
        name: student.name,
        rollNo: student.rollNo,
        email: student.konguEmail,
        department: student.department,
        passedOutYear: student.passingYear,
        linkedin: student.linkedin,
        phone: student.phone,
        otherEmail: student.personalEmail,
      });

      await alumni.save();
      await Student.deleteOne({ username: student.username });

      // Send Email
      const emailResult = await sendEmail({
        from: process.env.EMAIL_USER,
        to: student.konguEmail,
        subject: 'AlumniConnect: Moved to Alumni',
        text: `You have been moved to the Alumni database.\nUsername: ${student.konguEmail}\nPassword: Your existing password`,
      });

      if (!emailResult.success) {
        console.warn(`Student moved to alumni but email failed for ${student.konguEmail}: ${emailResult.error}`);
      }
    }
    res.status(200).json({ message: `Moved ${students.length} students to alumni` });
  } catch (err) {
    console.error('Manual alumni transition error:', err.message, err.stack);
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// Start Server and Initialize Admin
initializeAdmin().then(() => {
  app.listen(3000, () => console.log('Server running on port 3000'));
});