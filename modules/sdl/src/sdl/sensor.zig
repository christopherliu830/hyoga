pub const PropertiesID = @import("properties.zig").PropertiesID;

//pub const struct_SDL_Sensor = opaque {};
pub const Sensor = opaque {};

//pub const SDL_Sensor = struct_SDL_Sensor;
//pub const SDL_SensorID = Uint32;
pub const SensorID = u32;
//pub const SDL_SENSOR_INVALID: c_int = -1;
//pub const SDL_SENSOR_UNKNOWN: c_int = 0;
//pub const SDL_SENSOR_ACCEL: c_int = 1;
//pub const SDL_SENSOR_GYRO: c_int = 2;
//pub const SDL_SENSOR_ACCEL_L: c_int = 3;
//pub const SDL_SENSOR_GYRO_L: c_int = 4;
//pub const SDL_SENSOR_ACCEL_R: c_int = 5;
//pub const SDL_SENSOR_GYRO_R: c_int = 6;
//pub const enum_SDL_SensorType = c_int;
pub const SensorType = enum(c_uint) {
    sensor_invalid = -1,
    sensor_unknown = 0,
    sensor_accel = 1,
    sensor_gyro = 2,
    sensor_accel_l = 3,
    sensor_gyro_l = 4,
    sensor_accel_r = 5,
    sensor_gyro_r = 6,
};

//pub const SDL_SensorType = enum_SDL_SensorType;
//pub extern fn SDL_GetSensors(count: [*c]c_int) [*c]SDL_SensorID;
pub extern fn SDL_GetSensors(count: [*c]c_int) [*c]SensorID;
pub const getSensors = SDL_GetSensors;
//pub extern fn SDL_GetSensorNameForID(instance_id: SDL_SensorID) [*c]const u8;
pub extern fn SDL_GetSensorNameForID(instance_id: SensorID) [*c]const u8;
pub const getSensorNameForID = SDL_GetSensorNameForID;
//pub extern fn SDL_GetSensorTypeForID(instance_id: SDL_SensorID) SDL_SensorType;
pub extern fn SDL_GetSensorTypeForID(instance_id: SensorID) SensorType;
pub const getSensorTypeForID = SDL_GetSensorTypeForID;
//pub extern fn SDL_GetSensorNonPortableTypeForID(instance_id: SDL_SensorID) c_int;
pub extern fn SDL_GetSensorNonPortableTypeForID(instance_id: SensorID) c_int;
pub const getSensorNonPortableTypeForID = SDL_GetSensorNonPortableTypeForID;
//pub extern fn SDL_OpenSensor(instance_id: SDL_SensorID) ?*SDL_Sensor;
pub extern fn SDL_OpenSensor(instance_id: SensorID) ?*Sensor;
pub const openSensor = SDL_OpenSensor;
//pub extern fn SDL_GetSensorFromID(instance_id: SDL_SensorID) ?*SDL_Sensor;
pub extern fn SDL_GetSensorFromID(instance_id: SensorID) ?*Sensor;
pub const getSensorFromID = SDL_GetSensorFromID;
//pub extern fn SDL_GetSensorProperties(sensor: ?*SDL_Sensor) SDL_PropertiesID;
pub extern fn SDL_GetSensorProperties(sensor: ?*Sensor) PropertiesID;
pub const getSensorProperties = SDL_GetSensorProperties;
//pub extern fn SDL_GetSensorName(sensor: ?*SDL_Sensor) [*c]const u8;
pub extern fn SDL_GetSensorName(sensor: ?*Sensor) [*c]const u8;
pub const getSensorName = SDL_GetSensorName;
//pub extern fn SDL_GetSensorType(sensor: ?*SDL_Sensor) SDL_SensorType;
pub extern fn SDL_GetSensorType(sensor: ?*Sensor) SensorType;
pub const getSensorType = SDL_GetSensorType;
//pub extern fn SDL_GetSensorNonPortableType(sensor: ?*SDL_Sensor) c_int;
pub extern fn SDL_GetSensorNonPortableType(sensor: ?*Sensor) c_int;
pub const getSensorNonPortableType = SDL_GetSensorNonPortableType;
//pub extern fn SDL_GetSensorID(sensor: ?*SDL_Sensor) SDL_SensorID;
pub extern fn SDL_GetSensorID(sensor: ?*Sensor) SensorID;
pub const getSensorID = SDL_GetSensorID;
//pub extern fn SDL_GetSensorData(sensor: ?*SDL_Sensor, data: [*c]f32, num_values: c_int) SDL_bool;
pub extern fn SDL_GetSensorData(sensor: ?*Sensor, data: [*c]f32, num_values: c_int) bool;
pub const getSensorData = SDL_GetSensorData;
//pub extern fn SDL_CloseSensor(sensor: ?*SDL_Sensor) void;
pub extern fn SDL_CloseSensor(sensor: ?*Sensor) void;
pub const closeSensor = SDL_CloseSensor;
//pub extern fn SDL_UpdateSensors() void;
pub extern fn SDL_UpdateSensors() void;
pub const updateSensors = SDL_UpdateSensors;
