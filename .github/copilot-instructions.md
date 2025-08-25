# Rails 8.0.2.1 Application

Rails 8021 is a modern Rails 8.0.2.1 web application featuring the latest Rails technologies including Solid Cache, Solid Queue, Solid Cable, Hotwire (Turbo + Stimulus), importmap for JavaScript, and built-in Docker deployment with Kamal.

**ALWAYS reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

## Working Effectively

### Prerequisites and Environment Setup
- Ruby 3.2.3 is required (see .ruby-version file)
- Install Rails 8.0.2.1: `sudo gem install rails`
- Install Bundler: `sudo gem install bundler`

### Bootstrap, Build, and Test the Repository

**CRITICAL**: Set appropriate timeouts (60+ minutes) for build commands and (30+ minutes) for test commands.

1. **Install Dependencies**:
   ```bash
   cd /path/to/rails_8021
   bundle config set --local path vendor/bundle
   bundle install
   ```
   - Takes approximately 55 seconds. NEVER CANCEL. Set timeout to 5+ minutes.
   - If permission errors occur, use local bundle path as shown above.

2. **Database Setup**:
   ```bash
   bundle exec rails db:migrate
   bundle exec rails db:setup  # Run after migrations if needed
   ```
   - Takes approximately 2-3 seconds. Set timeout to 2+ minutes.
   - Uses SQLite3 by default in development and test environments.

3. **Run Tests**:
   ```bash
   bundle exec rails test
   bundle exec rails test:system
   ```
   - Test suite takes approximately 1-3 seconds. NEVER CANCEL. Set timeout to 10+ minutes.
   - System tests use Capybara with Selenium WebDriver and Chrome.

4. **Start Development Server**:
   ```bash
   bundle exec rails server -p 3000
   # OR use the setup script which starts server automatically
   bin/setup
   ```
   - Server starts in approximately 2-3 seconds.
   - Access at http://localhost:3000
   - Default welcome page shows Rails 8 landing page.

### Code Quality and Linting

**ALWAYS run these before committing or the CI (.github/workflows/ci.yml) will fail:**

1. **Ruby Code Style**:
   ```bash
   bundle exec rubocop
   bin/rubocop  # Alternative via binstub
   ```
   - Takes approximately 2 seconds. Set timeout to 5+ minutes.
   - Uses Rails Omakase style guide (see .rubocop.yml).

2. **Security Scanning**:
   ```bash
   bundle exec brakeman
   bin/brakeman  # Alternative via binstub
   ```
   - Takes approximately 1.7 seconds. Set timeout to 5+ minutes.
   - Scans for common Rails security vulnerabilities.

### Validation Requirements

**MANUAL VALIDATION REQUIREMENT**: After making changes, ALWAYS test actual functionality:

1. **Start the server**: `bundle exec rails server`
2. **Test basic routes**:
   - GET http://localhost:3000 (Rails welcome page)
   - GET http://localhost:3000/pages/home (sample controller)
   - GET http://localhost:3000/pages/about (sample controller)
3. **Run the test suite**: `bundle exec rails test`
4. **Run linting**: `bundle exec rubocop && bundle exec brakeman`

## Project Structure and Key Components

### Rails 8 Modern Features
- **Asset Pipeline**: Uses Propshaft (not Sprockets)
- **JavaScript**: Importmap-rails for ES6 modules, no Node.js required
- **CSS**: Integrated with Propshaft
- **Background Jobs**: Solid Queue (database-backed)
- **Caching**: Solid Cache (database-backed)
- **Action Cable**: Solid Cable (database-backed)
- **Frontend**: Hotwire (Turbo + Stimulus)

### Important Directories
- `app/`: Standard Rails application code
- `config/`: Configuration files
- `db/`: Database migrations and schema
- `test/`: Test suite (using Rails' built-in TestUnit)
- `bin/`: Executable scripts and binstubs
- `vendor/bundle/`: Local gem installation (bundler configured for local install)

### Available Commands
- `bin/rails`: Rails command line interface
- `bin/rake`: Rake task runner
- `bin/rubocop`: Code style linting
- `bin/brakeman`: Security scanning
- `bin/setup`: One-command project setup
- `bin/dev`: Development server (if configured)
- `bin/thrust`: HTTP acceleration server

### Deployment
- **Docker**: Dockerfile included for containerization
- **Kamal**: Modern deployment tool (replaces Capistrano)
  - Configuration in `config/deploy.yml`
  - Secrets in `.kamal/secrets`
  - Use `bundle exec kamal help` for deployment commands

## Common Issues and Workarounds

### Bundle Install Permission Issues
If `bundle install` fails with permission errors:
```bash
bundle config set --local path vendor/bundle
bundle install
```

### Database Issues
For fresh development database:
```bash
bundle exec rails db:drop db:create db:migrate db:seed
```

### Server Not Starting
If server fails to start, check:
1. Port 3000 is not in use: `lsof -i :3000`
2. Database is properly set up: `bundle exec rails db:migrate`
3. All gems are installed: `bundle install`

## Testing Guidelines

### Running Specific Tests
```bash
# Run all tests
bundle exec rails test

# Run specific test file
bundle exec rails test test/controllers/pages_controller_test.rb

# Run system tests
bundle exec rails test:system

# Run with specific pattern
bundle exec rails test -n test_home_page
```

### Adding New Tests
- Controller tests: `test/controllers/`
- Model tests: `test/models/`
- Integration tests: `test/integration/`
- System tests: `test/system/`

## CI/CD Pipeline

The repository includes GitHub Actions workflow (`.github/workflows/ci.yml`) that runs:
1. **Brakeman security scan**: `bin/brakeman --no-pager`
2. **Rubocop linting**: `bin/rubocop -f github`  
3. **Test suite**: `bin/rails db:test:prepare test test:system`

**CRITICAL**: Always run these locally before pushing:
```bash
bundle exec brakeman && bundle exec rubocop && bundle exec rails test
```

## Development Workflow

1. **Make changes** to application code
2. **Run tests** to ensure nothing breaks: `bundle exec rails test`
3. **Run linting**: `bundle exec rubocop`
4. **Run security scan**: `bundle exec brakeman`
5. **Start server** and manually test functionality: `bundle exec rails server`
6. **Test specific user scenarios** by navigating through the application
7. **Commit changes** only after all validations pass

## Timing Expectations and Timeout Settings

**NEVER CANCEL builds or long-running commands. Always use appropriate timeouts:**

- **Bundle install**: ~55 seconds (set timeout: 5+ minutes)
- **Database migrations**: ~2-3 seconds (set timeout: 2+ minutes)
- **Test suite**: ~1-3 seconds (set timeout: 10+ minutes)
- **Rubocop linting**: ~2 seconds (set timeout: 5+ minutes)
- **Brakeman security scan**: ~1.7 seconds (set timeout: 5+ minutes)
- **Server startup**: ~2-3 seconds (manual process)
- **Rails generators**: ~1 second (set timeout: 2+ minutes)

## Rails 8 Specific Notes

- **No Node.js required**: Rails 8 uses importmap for JavaScript management
- **No Redis required**: Solid Cache/Queue/Cable use the database
- **Docker-first**: Includes Dockerfile and .dockerignore
- **Modern defaults**: Uses modern Rails conventions and security settings
- **PWA support**: Includes service worker and manifest templates

Always ensure your changes work with these modern Rails 8 patterns and don't introduce dependencies that conflict with the streamlined approach.