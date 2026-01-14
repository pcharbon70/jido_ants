# Configure ExUnit with skip tag support
ExUnit.start(exclude: [skip: true])

# Set default test configuration
Application.put_env(:ant_colony, :plane_size, {20, 20})
