//! Box2d headers for hyoga
const std = @import("std");

const MAX_POLYGON_VERTICES = 8;
const B2_SECRET_COOKIE = 1152023;

pub const length_units_per_meter = 1;

pub const AABB = extern struct { lower_bound: Vec2, upper_bound: Vec2 };

pub const BodyEvents = opaque {};

pub const CastOutput = opaque {};

pub const CastResultFcn = opaque {};

pub const ContactEvents = opaque {};

pub const ContactData = opaque {};

pub const Counters = opaque {};

pub const CustomFilterFcn = opaque {};

pub const DebugDraw = opaque {};

pub const ExplosionDef = opaque {};

pub const Filter = extern struct {
    category_bits: u64 = 1,
    mask_bits: u64 = std.math.maxInt(u64),
    group_index: i32 = 0,
};

pub const MassData = opaque {};

pub const OverlapResultFcn = opaque {};

pub const PreSolveFcn = opaque {};

pub const Profile = opaque {};

pub const QueryFilter = opaque {};

pub const RayCastInput = opaque {};

pub const RayResult = opaque {};

pub const Rot = extern struct {
    /// Cosine
    c: f32,
    /// Sine
    s: f32,

    pub const identity: Rot = .{ .c = 1, .s = 0 };
};

pub const SensorEvents = opaque {};

pub const Transform = opaque {};

pub const TreeStats = opaque {};

pub const TaskCallback = ?*const fn (start_index: c_int, end_index: c_int, worker_index: u32, task_context: ?*anyopaque) void;

pub const EnqueueTaskCallback = ?*const fn (task: *TaskCallback, item_count: c_int, min_range: c_int, task_context: ?*anyopaque, user_context: ?*anyopaque) ?*anyopaque;

pub const FinishTaskCallback = ?*const fn (userTask: ?*anyopaque, userContext: ?*anyopaque) void;

pub const FrictionCallback = ?*const fn (friction_a: f32, material_a: c_int, friction_b: f32, material_b: c_int) f32;

pub const RestitutionCallback = ?*const fn (restitution_a: f32, material_a: c_int, restitution_b: f32, material_b: c_int) f32;

pub const Vec2 = extern struct {
    x: f32,
    y: f32,
    pub const zero: Vec2 = .{ .x = 0, .y = 0 };
};

pub const World = enum(u32) {
    null = 0,

    pub const Definition = extern struct {
        /// Gravity vector. Box2D has no up-vector defined.
        gravity: Vec2 = .{ .x = 0, .y = -10 },

        /// Restitution speed threshold, usually in m/s. Collisions above this
        /// speed have restitution applied (will bounce).
        restitution_threshold: f32 = length_units_per_meter,

        /// Threshold speed for hit events. Usually meters per second.
        hit_event_threshold: f32 = length_units_per_meter,

        /// Contact stiffness. Cycles per second. Increasing this increases the speed of overlap recovery, but can introduce jitter.
        contact_hertz: f32 = 30,

        /// Contact bounciness. Non-dimensional. You can speed up overlap recovery by decreasing this with
        /// the trade-off that overlap resolution becomes more energetic.
        contact_damping_ratio: f32 = 10,

        /// This parameter controls how fast overlap is resolved and usually has units of meters per second. This only
        /// puts a cap on the resolution speed. The resolution speed is increased by increasing the hertz and/or
        /// decreasing the damping ratio.
        contact_max_push_speed: f32 = 3 * length_units_per_meter,

        /// Joint stiffness. Cycles per second.
        joint_hertz: f32 = 60,

        /// Joint bounciness. Non-dimensional.
        joint_damping_ratio: f32 = 2.0,

        /// Maximum linear speed. Usually meters per second.
        maximum_linear_speed: f32 = 400 * length_units_per_meter,

        /// Optional mixing callback for friction. The default uses sqrt(frictionA * frictionB).
        frictionCallback: FrictionCallback = null,

        /// Optional mixing callback for restitution. The default uses max(restitutionA, restitutionB).
        restitutionCallback: RestitutionCallback = null,

        /// Can bodies go to sleep to improve performance
        enable_sleep: bool = true,

        /// Enable continuous collision
        enable_continuous: bool = true,

        /// Number of workers to use with the provided task system. Box2D performs best when using only
        /// performance cores and accessing a single L2 cache. Efficiency cores and hyper-threading provide
        /// little benefit and may even harm performance.
        /// @note Box2D does not create threads. This is the number of threads your applications has created
        /// that you are allocating to b2World_Step.
        /// @warning Do not modify the default value unless you are also providing a task system and providing
        /// task callbacks (enqueueTask and finishTask).
        worker_count: c_int = 0,

        /// Function to spawn tasks
        enqueueTask: EnqueueTaskCallback = null,

        /// Function to spawn tasks
        finishTask: FinishTaskCallback = null,

        /// User context that is provided to enqueueTask and finishTask
        user_task_context: ?*anyopaque = null,

        /// User data
        user_data: ?*anyopaque = null,

        internal_value: c_int = B2_SECRET_COOKIE,
    };

    pub const create = b2CreateWorld;
    pub const Destroy = b2DestroyWorld;
    pub const IsValid = b2World_IsValid;
    pub const step = b2World_Step;
    pub const Draw = b2World_Draw;
    pub const GetBodyEvents = b2World_GetBodyEvents;
    pub const GetSensorEvents = b2World_GetSensorEvents;
    pub const GetContactEvents = b2World_GetContactEvents;
    pub const OverlapAABB = b2World_OverlapAABB;
    pub const OverlapPoint = b2World_OverlapPoint;
    pub const OverlapCircle = b2World_OverlapCircle;
    pub const OverlapCapsule = b2World_OverlapCapsule;
    pub const OverlapPolygon = b2World_OverlapPolygon;
    pub const CastRay = b2World_CastRay;
    pub const CastRayClosest = b2World_CastRayClosest;
    pub const CastCircle = b2World_CastCircle;
    pub const CastCapsule = b2World_CastCapsule;
    pub const CastPolygon = b2World_CastPolygon;
    pub const EnableSleeping = b2World_EnableSleeping;
    pub const IsSleepingEnabled = b2World_IsSleepingEnabled;
    pub const EnableContinuous = b2World_EnableContinuous;
    pub const IsContinuousEnabled = b2World_IsContinuousEnabled;
    pub const SetRestitutionThreshold = b2World_SetRestitutionThreshold;
    pub const GetRestitutionThreshold = b2World_GetRestitutionThreshold;
    pub const SetHitEventThreshold = b2World_SetHitEventThreshold;
    pub const GetHitEventThreshold = b2World_GetHitEventThreshold;
    pub const SetCustomFilterCallback = b2World_SetCustomFilterCallback;
    pub const SetPreSolveCallback = b2World_SetPreSolveCallback;
    pub const SetGravity = b2World_SetGravity;
    pub const GetGravity = b2World_GetGravity;
    pub const Explode = b2World_Explode;
    pub const SetContactTuning = b2World_SetContactTuning;
    pub const SetJointTuning = b2World_SetJointTuning;
    pub const SetMaximumLinearSpeed = b2World_SetMaximumLinearSpeed;
    pub const GetMaximumLinearSpeed = b2World_GetMaximumLinearSpeed;
    pub const EnableWarmStarting = b2World_EnableWarmStarting;
    pub const IsWarmStartingEnabled = b2World_IsWarmStartingEnabled;
    pub const GetAwakeBodyCount = b2World_GetAwakeBodyCount;
    pub const GetProfile = b2World_GetProfile;
    pub const GetCounters = b2World_GetCounters;
    pub const SetUserData = b2World_SetUserData;
    pub const GetUserData = b2World_GetUserData;
    pub const SetFrictionCallback = b2World_SetFrictionCallback;
    pub const SetRestitutionCallback = b2World_SetRestitutionCallback;
    pub const DumpMemoryStats = b2World_DumpMemoryStats;
    pub const RebuildStaticTree = b2World_RebuildStaticTree;
    pub const EnableSpeculative = b2World_EnableSpeculative;
};

pub const Body = enum(u64) {
    null = 0,

    pub const Type = enum(u32) { static, kinematic, dynamic, count };
    pub const Definition = extern struct {
        /// The body type: static, kinematic, or dynamic.
        type: Type = .static,

        /// The initial world position of the body. Bodies should be created with the desired position.
        /// @note Creating bodies at the origin and then moving them nearly doubles the cost of body creation, especially
        /// if the body is moved after shapes have been added.
        position: Vec2 = .zero,

        /// The initial world rotation of the body. Use b2MakeRot() if you have an angle.
        rotation: Rot = .identity,

        /// The initial linear velocity of the body's origin. Usually in meters per second.
        linear_velocity: Vec2 = .zero,

        /// The initial angular velocity of the body. Radians per second.
        angular_velocity: f32 = 0,

        /// Linear damping is used to reduce the linear velocity. The damping parameter
        /// can be larger than 1 but the damping effect becomes sensitive to the
        /// time step when the damping parameter is large.
        /// Generally linear damping is undesirable because it makes objects move slowly
        /// as if they are floating.
        linear_damping: f32 = 0,

        /// Angular damping is used to reduce the angular velocity. The damping parameter
        /// can be larger than 1.0f but the damping effect becomes sensitive to the
        /// time step when the damping parameter is large.
        /// Angular damping can be use slow down rotating bodies.
        angular_damping: f32 = 0,

        /// Scale the gravity applied to this body. Non-dimensional.
        gravity_scale: f32 = 1,

        /// Sleep speed threshold, default is 0.05 meters per second
        sleep_threshold: f32 = 0.05 * length_units_per_meter,

        /// Optional body name for debugging. Up to 31 characters (excluding null termination)
        name: ?[*:0]const u8 = null,

        /// Use this to store application specific body data.
        user_data: ?*anyopaque = null,

        /// Set this flag to false if this body should never fall asleep.
        enable_sleep: bool = true,

        /// Is this body initially awake or sleeping?
        is_awake: bool = true,

        /// Should this body be prevented from rotating? Useful for characters.
        fixed_rotation: bool = false,

        /// Treat this body as high speed object that performs continuous collision detection
        /// against dynamic and kinematic bodies, but not other bullet bodies.
        /// @warning Bullets should be used sparingly. They are not a solution for general dynamic-versus-dynamic
        /// continuous collision. They may interfere with joint constraints.
        is_bullet: bool = false,

        /// Used to disable a body. A disabled body does not move or collide.
        is_enabled: bool = true,

        /// This allows this body to bypass rotational speed limits. Should only be used
        /// for circular objects, like wheels.
        allow_fast_rotation: bool = false,

        /// Used internally to detect a valid definition. DO NOT SET.
        internal_value: c_int = B2_SECRET_COOKIE,
    };

    pub const create = b2CreateBody;
    pub const Destroy = b2DestroyBody;
    pub const IsValid = b2Body_IsValid;
    pub const GetType = b2Body_GetType;
    pub const SetType = b2Body_SetType;
    pub const SetName = b2Body_SetName;
    pub const GetName = b2Body_GetName;
    pub const SetUserData = b2Body_SetUserData;
    pub const GetUserData = b2Body_GetUserData;
    pub const GetPosition = b2Body_GetPosition;
    pub const GetRotation = b2Body_GetRotation;
    pub const GetTransform = b2Body_GetTransform;
    pub const SetTransform = b2Body_SetTransform;
    pub const GetLocalPoint = b2Body_GetLocalPoint;
    pub const GetWorldPoint = b2Body_GetWorldPoint;
    pub const GetLocalVector = b2Body_GetLocalVector;
    pub const GetWorldVector = b2Body_GetWorldVector;
    pub const GetLinearVelocity = b2Body_GetLinearVelocity;
    pub const GetAngularVelocity = b2Body_GetAngularVelocity;
    pub const SetLinearVelocity = b2Body_SetLinearVelocity;
    pub const SetAngularVelocity = b2Body_SetAngularVelocity;
    pub const GetLocalPointVelocity = b2Body_GetLocalPointVelocity;
    pub const GetWorldPointVelocity = b2Body_GetWorldPointVelocity;
    pub const ApplyForce = b2Body_ApplyForce;
    pub const ApplyForceToCenter = b2Body_ApplyForceToCenter;
    pub const ApplyTorque = b2Body_ApplyTorque;
    pub const ApplyLinearImpulse = b2Body_ApplyLinearImpulse;
    pub const ApplyLinearImpulseToCenter = b2Body_ApplyLinearImpulseToCenter;
    pub const ApplyAngularImpulse = b2Body_ApplyAngularImpulse;
    pub const GetMass = b2Body_GetMass;
    pub const GetRotationalInertia = b2Body_GetRotationalInertia;
    pub const GetLocalCenterOfMass = b2Body_GetLocalCenterOfMass;
    pub const GetWorldCenterOfMass = b2Body_GetWorldCenterOfMass;
    pub const SetMassData = b2Body_SetMassData;
    pub const GetMassData = b2Body_GetMassData;
    pub const ApplyMassFromShapes = b2Body_ApplyMassFromShapes;
    pub const SetLinearDamping = b2Body_SetLinearDamping;
    pub const GetLinearDamping = b2Body_GetLinearDamping;
    pub const SetAngularDamping = b2Body_SetAngularDamping;
    pub const GetAngularDamping = b2Body_GetAngularDamping;
    pub const SetGravityScale = b2Body_SetGravityScale;
    pub const GetGravityScale = b2Body_GetGravityScale;
    pub const IsAwake = b2Body_IsAwake;
    pub const SetAwake = b2Body_SetAwake;
    pub const EnableSleep = b2Body_EnableSleep;
    pub const IsSleepEnabled = b2Body_IsSleepEnabled;
    pub const SetSleepThreshold = b2Body_SetSleepThreshold;
    pub const GetSleepThreshold = b2Body_GetSleepThreshold;
    pub const IsEnabled = b2Body_IsEnabled;
    pub const Disable = b2Body_Disable;
    pub const Enable = b2Body_Enable;
    pub const SetFixedRotation = b2Body_SetFixedRotation;
    pub const IsFixedRotation = b2Body_IsFixedRotation;
    pub const SetBullet = b2Body_SetBullet;
    pub const IsBullet = b2Body_IsBullet;
    pub const EnableContactEvents = b2Body_EnableContactEvents;
    pub const EnableHitEvents = b2Body_EnableHitEvents;
    pub const GetWorld = b2Body_GetWorld;
    pub const GetShapeCount = b2Body_GetShapeCount;
    pub const GetShapes = b2Body_GetShapes;
    pub const GetJointCount = b2Body_GetJointCount;
    pub const GetJoints = b2Body_GetJoints;
    pub const GetContactCapacity = b2Body_GetContactCapacity;
    pub const GetContactData = b2Body_GetContactData;
    pub const ComputeAABB = b2Body_ComputeAABB;
};

pub const Shape = enum(u64) {
    null = 0,

    pub const Definition = extern struct {
        /// Use this to store application specific shape data.
        user_data: ?*anyopaque = null,

        /// The Coulomb (dry) friction coefficient, usually in the range [0,1].
        friction: f32 = 0.3,

        /// The coefficient of restitution (bounce) usually in the range [0,1].
        /// https://en.wikipedia.org/wiki/Coefficient_of_restitution
        restitution: f32 = 0,

        /// The rolling resistance usually in the range [0,1].
        /// todo
        rolling_resistance: f32 = 0,

        /// User material identifier. This is passed with query results and to friction and restitution
        /// combining functions. It is not used internally.
        material: c_int = 0,

        /// The density, usually in kg/m^2.
        density: f32 = 1,

        /// Collision filtering data.
        filter: Filter = .{},

        /// Custom debug draw color.
        custom_color: u32 = 0,

        /// A sensor shape generates overlap events but never generates a collision response.
        /// Sensors do not collide with other sensors and do not have continuous collision.
        /// Instead, use a ray or shape cast for those scenarios.
        is_sensor: bool = false,

        /// Enable contact events for this shape. Only applies to kinematic and dynamic bodies. Ignored for sensors.
        enable_contact_events: bool = false,

        /// Enable hit events for this shape. Only applies to kinematic and dynamic bodies. Ignored for sensors.
        enable_hit_events: bool = false,

        /// Enable pre-solve contact events for this shape. Only applies to dynamic bodies. These are expensive
        /// and must be carefully handled due to threading. Ignored for sensors.
        enable_pre_solve_events: bool = false,

        /// Normally shapes on static bodies don't invoke contact creation when they are added to the world. This overrides
        /// that behavior and causes contact creation. This significantly slows down static body creation which can be important
        /// when there are many static shapes.
        /// This is implicitly always true for sensors, dynamic bodies, and kinematic bodies.
        invoke_contact_creation: bool = false,

        /// Should the body update the mass properties when this shape is created. Default is true.
        update_body_mass: bool = true,

        /// Used internally to detect a valid definition. DO NOT SET.
        internal_value: c_int = B2_SECRET_COOKIE,
    };

    pub const Type = enum(u32) {
        circle,
        capsule,
        segment,
        polygon,
        chain_segment,
        count,
    };

    pub const Circle = extern struct {
        center: Vec2,
        radius: f32,
    };

    pub const Capsule = extern struct {
        center_1: Vec2,
        center_2: Vec2,
        radius: f32,
    };

    pub const Segment = extern struct {
        point_1: Vec2,
        point_2: Vec2,
    };

    pub const Polygon = extern struct {
        vertices: [MAX_POLYGON_VERTICES]Vec2,
        normals: [MAX_POLYGON_VERTICES]Vec2,
        centroid: Vec2,
        radius: f32,
        count: c_int,

        pub const makeBox = b2MakeBox;
    };
    pub const ChainSegment = extern struct {
        ghost_1: Vec2,
        segment: Vec2,
        ghost_2: Vec2,
        chain_id: c_int,
    };

    pub const createCircleShape = b2CreateCircleShape;
    pub const CreateSegmentShape = b2CreateSegmentShape;
    pub const CreateCapsuleShape = b2CreateCapsuleShape;
    pub const createPolygonShape = b2CreatePolygonShape;
    pub const DestroyShape = b2DestroyShape;
    pub const IsValid = b2Shape_IsValid;
    pub const GetType = b2Shape_GetType;
    pub const GetBody = b2Shape_GetBody;
    pub const GetWorld = b2Shape_GetWorld;
    pub const IsSensor = b2Shape_IsSensor;
    pub const SetUserData = b2Shape_SetUserData;
    pub const GetUserData = b2Shape_GetUserData;
    pub const SetDensity = b2Shape_SetDensity;
    pub const GetDensity = b2Shape_GetDensity;
    pub const SetFriction = b2Shape_SetFriction;
    pub const GetFriction = b2Shape_GetFriction;
    pub const SetRestitution = b2Shape_SetRestitution;
    pub const GetRestitution = b2Shape_GetRestitution;
    pub const SetMaterial = b2Shape_SetMaterial;
    pub const GetMaterial = b2Shape_GetMaterial;
    pub const GetFilter = b2Shape_GetFilter;
    pub const SetFilter = b2Shape_SetFilter;
    pub const EnableContactEvents = b2Shape_EnableContactEvents;
    pub const AreContactEventsEnabled = b2Shape_AreContactEventsEnabled;
    pub const EnablePreSolveEvents = b2Shape_EnablePreSolveEvents;
    pub const ArePreSolveEventsEnabled = b2Shape_ArePreSolveEventsEnabled;
    pub const EnableHitEvents = b2Shape_EnableHitEvents;
    pub const AreHitEventsEnabled = b2Shape_AreHitEventsEnabled;
    pub const TestPoint = b2Shape_TestPoint;
    pub const RayCast = b2Shape_RayCast;
    pub const GetCircle = b2Shape_GetCircle;
    pub const GetSegment = b2Shape_GetSegment;
    pub const GetChainSegment = b2Shape_GetChainSegment;
    pub const GetCapsule = b2Shape_GetCapsule;
    pub const GetPolygon = b2Shape_GetPolygon;
    pub const SetCircle = b2Shape_SetCircle;
    pub const SetCapsule = b2Shape_SetCapsule;
    pub const SetSegment = b2Shape_SetSegment;
    pub const SetPolygon = b2Shape_SetPolygon;
    pub const GetParentChain = b2Shape_GetParentChain;
    pub const GetContactCapacity = b2Shape_GetContactCapacity;
    pub const GetContactData = b2Shape_GetContactData;
    pub const GetSensorCapacity = b2Shape_GetSensorCapacity;
    pub const GetSensorOverlaps = b2Shape_GetSensorOverlaps;
    pub const GetAABB = b2Shape_GetAABB;
    pub const GetMassData = b2Shape_GetMassData;
    pub const GetClosestPoint = b2Shape_GetClosestPoint;
};

const Chain = enum(u64) {
    null = 0,

    pub const Definition = extern struct {};

    pub const CreateChain = b2CreateChain;
    pub const DestroyChain = b2DestroyChain;
    pub const GetWorld = b2Chain_GetWorld;
    pub const GetSegmentCount = b2Chain_GetSegmentCount;
    pub const GetSegments = b2Chain_GetSegments;
    pub const SetFriction = b2Chain_SetFriction;
    pub const GetFriction = b2Chain_GetFriction;
    pub const SetRestitution = b2Chain_SetRestitution;
    pub const GetRestitution = b2Chain_GetRestitution;
    pub const SetMaterial = b2Chain_SetMaterial;
    pub const GetMaterial = b2Chain_GetMaterial;
    pub const IsValid = b2Chain_IsValid;
};

const Joint = enum(u64) {
    null = 0,

    pub const Type = enum(u32) {
        distance,
        motor,
        mouse,
        null,
        prismatic,
        revolute,
        weld,
        wheel,
    };

    pub const Distance = enum(u64) {
        pub const Definition = extern struct {};
        pub fn asJoint(self: @This()) Joint {
            return @enumFromInt(@intFromEnum(self));
        }
        pub const Create = b2CreateDistanceJoint;
        pub const SetLength = b2DistanceJoint_SetLength;
        pub const GetLength = b2DistanceJoint_GetLength;
        pub const EnableSpring = b2DistanceJoint_EnableSpring;
        pub const IsSpringEnabled = b2DistanceJoint_IsSpringEnabled;
        pub const SetSpringHertz = b2DistanceJoint_SetSpringHertz;
        pub const SetSpringDampingRatio = b2DistanceJoint_SetSpringDampingRatio;
        pub const GetSpringHertz = b2DistanceJoint_GetSpringHertz;
        pub const GetSpringDampingRatio = b2DistanceJoint_GetSpringDampingRatio;
        pub const EnableLimit = b2DistanceJoint_EnableLimit;
        pub const IsLimitEnabled = b2DistanceJoint_IsLimitEnabled;
        pub const SetLengthRange = b2DistanceJoint_SetLengthRange;
        pub const GetMinLength = b2DistanceJoint_GetMinLength;
        pub const GetMaxLength = b2DistanceJoint_GetMaxLength;
        pub const GetCurrentLength = b2DistanceJoint_GetCurrentLength;
        pub const EnableMotor = b2DistanceJoint_EnableMotor;
        pub const IsMotorEnabled = b2DistanceJoint_IsMotorEnabled;
        pub const SetMotorSpeed = b2DistanceJoint_SetMotorSpeed;
        pub const GetMotorSpeed = b2DistanceJoint_GetMotorSpeed;
        pub const SetMaxMotorForce = b2DistanceJoint_SetMaxMotorForce;
        pub const GetMaxMotorForce = b2DistanceJoint_GetMaxMotorForce;
    };

    pub const Motor = enum(64) {
        pub const Definition = extern struct {};
        pub fn asJoint(self: @This()) Joint {
            return @enumFromInt(@intFromEnum(self));
        }
        pub const Create = b2CreateMotorJoint;
        pub const SetLinearOffset = b2MotorJoint_SetLinearOffset;
        pub const GetLinearOffset = b2MotorJoint_GetLinearOffset;
        pub const SetAngularOffset = b2MotorJoint_SetAngularOffset;
        pub const GetAngularOffset = b2MotorJoint_GetAngularOffset;
        pub const SetMaxForce = b2MotorJoint_SetMaxForce;
        pub const GetMaxForce = b2MotorJoint_GetMaxForce;
        pub const SetMaxTorque = b2MotorJoint_SetMaxTorque;
        pub const GetMaxTorque = b2MotorJoint_GetMaxTorque;
        pub const SetCorrectionFactor = b2MotorJoint_SetCorrectionFactor;
    };

    pub const Mouse = enum(u64) {
        pub const Definition = extern struct {};
        pub fn asJoint(self: @This()) Joint {
            return @enumFromInt(@intFromEnum(self));
        }
        pub const Create = b2CreateMouseJoint;
        pub const SetTarget = b2MouseJoint_SetTarget;
        pub const GetTarget = b2MouseJoint_GetTarget;
        pub const SetSpringHertz = b2MouseJoint_SetSpringHertz;
        pub const GetSpringHertz = b2MouseJoint_GetSpringHertz;
        pub const SetSpringDampingRatio = b2MouseJoint_SetSpringDampingRatio;
        pub const GetSpringDampingRatio = b2MouseJoint_GetSpringDampingRatio;
        pub const SetMaxForce = b2MouseJoint_SetMaxForce;
        pub const GetMaxForce = b2MouseJoint_GetMaxForce;
    };

    pub const Null = enum(u64) {
        pub const Definition = extern struct {};
        pub fn asJoint(self: @This()) Joint {
            return @enumFromInt(@intFromEnum(self));
        }
        pub const Create = b2CreateNullJoint;
    };

    pub const Prismatic = enum(u64) {
        pub const Definition = extern struct {};
        pub fn asJoint(self: @This()) Joint {
            return @enumFromInt(@intFromEnum(self));
        }
        pub const Create = b2CreatePrismaticJoint;
        pub const EnableSpring = b2PrismaticJoint_EnableSpring;
        pub const IsSpringEnabled = b2PrismaticJoint_IsSpringEnabled;
        pub const SetSpringHertz = b2PrismaticJoint_SetSpringHertz;
        pub const GetSpringHertz = b2PrismaticJoint_GetSpringHertz;
        pub const SetSpringDampingRatio = b2PrismaticJoint_SetSpringDampingRatio;
        pub const GetSpringDampingRatio = b2PrismaticJoint_GetSpringDampingRatio;
        pub const EnableLimit = b2PrismaticJoint_EnableLimit;
        pub const IsLimitEnabled = b2PrismaticJoint_IsLimitEnabled;
        pub const GetLowerLimit = b2PrismaticJoint_GetLowerLimit;
        pub const GetUpperLimit = b2PrismaticJoint_GetUpperLimit;
        pub const SetLimits = b2PrismaticJoint_SetLimits;
        pub const EnableMotor = b2PrismaticJoint_EnableMotor;
        pub const IsMotorEnabled = b2PrismaticJoint_IsMotorEnabled;
        pub const SetMotorSpeed = b2PrismaticJoint_SetMotorSpeed;
        pub const GetMotorSpeed = b2PrismaticJoint_GetMotorSpeed;
        pub const SetMaxMotorForce = b2PrismaticJoint_SetMaxMotorForce;
        pub const GetMaxMotorForce = b2PrismaticJoint_GetMaxMotorForce;
        pub const GetMotorForce = b2PrismaticJoint_GetMotorForce;
        pub const GetTranslation = b2PrismaticJoint_GetTranslation;
        pub const GetSpeed = b2PrismaticJoint_GetSpeed;
    };

    pub const Revolute = enum(u64) {
        pub const Definition = extern struct {};
        pub fn asJoint(self: @This()) Joint {
            return @enumFromInt(@intFromEnum(self));
        }
        pub const Create = b2CreateRevoluteJoint;
        pub const EnableSpring = b2RevoluteJoint_EnableSpring;
        pub const IsSpringEnabled = b2RevoluteJoint_IsSpringEnabled;
        pub const SetSpringHertz = b2RevoluteJoint_SetSpringHertz;
        pub const GetSpringHertz = b2RevoluteJoint_GetSpringHertz;
        pub const SetSpringDampingRatio = b2RevoluteJoint_SetSpringDampingRatio;
        pub const GetSpringDampingRatio = b2RevoluteJoint_GetSpringDampingRatio;
        pub const GetAngle = b2RevoluteJoint_GetAngle;
        pub const EnableLimit = b2RevoluteJoint_EnableLimit;
        pub const IsLimitEnabled = b2RevoluteJoint_IsLimitEnabled;
        pub const GetLowerLimit = b2RevoluteJoint_GetLowerLimit;
        pub const GetUpperLimit = b2RevoluteJoint_GetUpperLimit;
        pub const SetLimits = b2RevoluteJoint_SetLimits;
        pub const EnableMotor = b2RevoluteJoint_EnableMotor;
        pub const IsMotorEnabled = b2RevoluteJoint_IsMotorEnabled;
        pub const SetMotorSpeed = b2RevoluteJoint_SetMotorSpeed;
        pub const GetMotorSpeed = b2RevoluteJoint_GetMotorSpeed;
        pub const GetMotorTorque = b2RevoluteJoint_GetMotorTorque;
        pub const SetMaxMotorTorque = b2RevoluteJoint_SetMaxMotorTorque;
        pub const GetMaxMotorTorque = b2RevoluteJoint_GetMaxMotorTorque;
    };

    pub const Weld = enum(u64) {
        pub const Definition = extern struct {};
        pub fn asJoint(self: @This()) Joint {
            return @enumFromInt(@intFromEnum(self));
        }
        pub const Create = b2CreateWeldJoint;
        pub const GetReferenceAngle = b2WeldJoint_GetReferenceAngle;
        pub const SetReferenceAngle = b2WeldJoint_SetReferenceAngle;
        pub const SetLinearHertz = b2WeldJoint_SetLinearHertz;
        pub const GetLinearHertz = b2WeldJoint_GetLinearHertz;
        pub const SetLinearDampingRatio = b2WeldJoint_SetLinearDampingRatio;
        pub const GetLinearDampingRatio = b2WeldJoint_GetLinearDampingRatio;
        pub const SetAngularHertz = b2WeldJoint_SetAngularHertz;
        pub const GetAngularHertz = b2WeldJoint_GetAngularHertz;
        pub const SetAngularDampingRatio = b2WeldJoint_SetAngularDampingRatio;
        pub const GetAngularDampingRatio = b2WeldJoint_GetAngularDampingRatio;
    };

    pub const Wheel = enum(u64) {
        pub const Definition = extern struct {};
        pub fn asJoint(self: @This()) Joint {
            return @enumFromInt(@intFromEnum(self));
        }
        pub const Create = b2CreateWheelJoint;
        pub const EnableSpring = b2WheelJoint_EnableSpring;
        pub const IsSpringEnabled = b2WheelJoint_IsSpringEnabled;
        pub const SetSpringHertz = b2WheelJoint_SetSpringHertz;
        pub const GetSpringHertz = b2WheelJoint_GetSpringHertz;
        pub const SetSpringDampingRatio = b2WheelJoint_SetSpringDampingRatio;
        pub const GetSpringDampingRatio = b2WheelJoint_GetSpringDampingRatio;
        pub const EnableLimit = b2WheelJoint_EnableLimit;
        pub const IsLimitEnabled = b2WheelJoint_IsLimitEnabled;
        pub const GetLowerLimit = b2WheelJoint_GetLowerLimit;
        pub const GetUpperLimit = b2WheelJoint_GetUpperLimit;
        pub const SetLimits = b2WheelJoint_SetLimits;
        pub const EnableMotor = b2WheelJoint_EnableMotor;
        pub const IsMotorEnabled = b2WheelJoint_IsMotorEnabled;
        pub const SetMotorSpeed = b2WheelJoint_SetMotorSpeed;
        pub const GetMotorSpeed = b2WheelJoint_GetMotorSpeed;
        pub const SetMaxMotorTorque = b2WheelJoint_SetMaxMotorTorque;
        pub const GetMaxMotorTorque = b2WheelJoint_GetMaxMotorTorque;
        pub const GetMotorTorque = b2WheelJoint_GetMotorTorque;
    };

    pub const Destroy = b2DestroyJoint;
    pub const IsValid = b2Joint_IsValid;
    pub const GetType = b2Joint_GetType;
    pub const GetBodyA = b2Joint_GetBodyA;
    pub const GetBodyB = b2Joint_GetBodyB;
    pub const GetWorld = b2Joint_GetWorld;
    pub const GetLocalAnchorA = b2Joint_GetLocalAnchorA;
    pub const GetLocalAnchorB = b2Joint_GetLocalAnchorB;
    pub const SetCollideConnected = b2Joint_SetCollideConnected;
    pub const GetCollideConnected = b2Joint_GetCollideConnected;
    pub const SetUserData = b2Joint_SetUserData;
    pub const GetUserData = b2Joint_GetUserData;
    pub const WakeBodies = b2Joint_WakeBodies;
    pub const GetConstraintForce = b2Joint_GetConstraintForce;
    pub const GetConstraintTorque = b2Joint_GetConstraintTorque;
};

/// Create a world for rigid body simulation. A world contains bodies, shapes, and constraints. You make create
/// up to 128 worlds. Each world is completely independent and may be simulated in parallel.
/// @return the world id.
extern fn b2CreateWorld(def: *const World.Definition) World;

/// Destroy a world
extern fn b2DestroyWorld(world: World) void;

/// World id validation. Provides validation for up to 64K allocations.
extern fn b2World_IsValid(id: World) bool;

/// Simulate a world for one time step. This performs collision detection, integration, and constraint solution.
/// @param worldId The world to simulate
/// @param timeStep The amount of time to simulate, this should be a fixed number. Usually 1/60.
/// @param subStepCount The number of sub-steps, increasing the sub-step count can increase accuracy. Usually 4.
extern fn b2World_Step(world: World, time_step: f32, sub_step_count: c_int) void;

/// Call this to draw shapes and other debug draw data
extern fn b2World_Draw(world: World, draw: *DebugDraw) void;

/// Get the body events for the current time step. The event data is transient. Do not store a reference to this data.
extern fn b2World_GetBodyEvents(world: World) BodyEvents;

/// Get sensor events for the current time step. The event data is transient. Do not store a reference to this data.
extern fn b2World_GetSensorEvents(world: World) SensorEvents;

/// Get contact events for this current time step. The event data is transient. Do not store a reference to this data.
extern fn b2World_GetContactEvents(world: World) ContactEvents;

/// Overlap test for all shapes that *potentially* overlap the provided AABB
extern fn b2World_OverlapAABB(world: World, aabb: AABB, filter: QueryFilter, fcn: OverlapResultFcn, context: ?*anyopaque) TreeStats;

/// Overlap test for for all shapes that overlap the provided point.
extern fn b2World_OverlapPoint(world: World, point: Vec2, transform: Transform, filter: QueryFilter, fcn: OverlapResultFcn, context: ?*anyopaque) TreeStats;

/// Overlap test for for all shapes that overlap the provided circle. A zero radius may be used for a point query.
extern fn b2World_OverlapCircle(world: World, circle: *const Shape.Circle, transform: Transform, filter: QueryFilter, fcn: OverlapResultFcn, context: ?*anyopaque) TreeStats;

/// Overlap test for all shapes that overlap the provided capsule
extern fn b2World_OverlapCapsule(world: World, capsule: *const Shape.Capsule, transform: Transform, filter: QueryFilter, fcn: OverlapResultFcn, context: ?*anyopaque) TreeStats;

/// Overlap test for all shapes that overlap the provided polygon
extern fn b2World_OverlapPolygon(world: World, polygon: *const Shape.Polygon, transform: Transform, filter: QueryFilter, fcn: OverlapResultFcn, context: ?*anyopaque) TreeStats;

/// Cast a ray into the world to collect shapes in the path of the ray.
/// Your callback function controls whether you get the closest point, any point, or n-points.
/// The ray-cast ignores shapes that contain the starting point.
/// note The callback function may receive shapes in any order
/// param worldId The world to cast the ray against
/// @param origin The start point of the ray
/// @param translation The translation of the ray from the start point to the end point
/// @param filter Contains bit flags to filter unwanted shapes from the results
/// @param fcn A user implemented callback function
/// @param context A user context that is passed along to the callback function
/// @return traversal performance counters
extern fn b2World_CastRay(world: World, origin: Vec2, translation: Vec2, filter: QueryFilter, fcn: CastResultFcn, context: ?*anyopaque) TreeStats;

/// Cast a ray into the world to collect the closest hit. This is a convenience function.
/// This is less general than b2World_CastRay() and does not allow for custom filtering.
extern fn b2World_CastRayClosest(world: World, origin: Vec2, translation: Vec2, filter: QueryFilter) RayResult;

/// Cast a circle through the world. Similar to a cast ray except that a circle is cast instead of a point.
/// @see b2World_CastRay
extern fn b2World_CastCircle(world: World, circle: *const Shape.Circle, originTransform: Transform, translation: Vec2, filter: QueryFilter, fcn: CastResultFcn, context: ?*anyopaque) TreeStats;

/// Cast a capsule through the world. Similar to a cast ray except that a capsule is cast instead of a point.
/// @see b2World_CastRay
extern fn b2World_CastCapsule(world: World, capsule: *const Shape.Capsule, originTransform: Transform, translation: Vec2, filter: QueryFilter, fcn: CastResultFcn, context: ?*anyopaque) TreeStats;

/// Cast a polygon through the world. Similar to a cast ray except that a polygon is cast instead of a point.
/// @see b2World_CastRay
extern fn b2World_CastPolygon(world: World, polygon: *const Shape.Polygon, originTransform: Transform, translation: Vec2, filter: QueryFilter, fcn: CastResultFcn, context: ?*anyopaque) TreeStats;

/// Enable/disable sleep. If your application does not need sleeping, you can gain some performance
/// by disabling sleep completely at the world level.
/// @see b2WorldDef
extern fn b2World_EnableSleeping(world: World, flag: bool) void;

/// Is body sleeping enabled?
extern fn b2World_IsSleepingEnabled(world: World) bool;

/// Enable/disable continuous collision between dynamic and static bodies. Generally you should keep continuous
/// collision enabled to prevent fast moving objects from going through static objects. The performance gain from
/// disabling continuous collision is minor.
/// @see b2WorldDef
extern fn b2World_EnableContinuous(world: World, flag: bool) void;

/// Is continuous collision enabled?
extern fn b2World_IsContinuousEnabled(world: World) bool;

/// Adjust the restitution threshold. It is recommended not to make this value very small
/// because it will prevent bodies from sleeping. Usually in meters per second.
/// @see b2WorldDef
extern fn b2World_SetRestitutionThreshold(world: World, value: f32) void;

/// Get the the restitution speed threshold. Usually in meters per second.
extern fn b2World_GetRestitutionThreshold(world: World) f32;

/// Adjust the hit event threshold. This controls the collision speed needed to generate a b2ContactHitEvent.
/// Usually in meters per second.
/// @see b2WorldDef::hitEventThreshold
extern fn b2World_SetHitEventThreshold(world: World, value: f32) void;

/// Get the the hit event speed threshold. Usually in meters per second.
extern fn b2World_GetHitEventThreshold(world: World) f32;

/// Register the custom filter callback. This is optional.
extern fn b2World_SetCustomFilterCallback(world: World, fcn: CustomFilterFcn, context: ?*anyopaque) void;

/// Register the pre-solve callback. This is optional.
extern fn b2World_SetPreSolveCallback(world: World, fcn: PreSolveFcn, context: ?*anyopaque) void;

/// Set the gravity vector for the entire world. Box2D has no concept of an up direction and this
/// is left as a decision for the application. Usually in m/s^2.
/// @see b2WorldDef
extern fn b2World_SetGravity(world: World, gravity: Vec2) void;

/// Get the gravity vector
extern fn b2World_GetGravity(world: World) void;

/// Apply a radial explosion
/// @param worldId The world id
/// @param explosionDef The explosion definition
extern fn b2World_Explode(world: World, explosion_def: *const ExplosionDef) void;

/// Adjust contact tuning parameters
/// @param worldId The world id
/// @param hertz The contact stiffness (cycles per second)
/// @param dampingRatio The contact bounciness with 1 being critical damping (non-dimensional)
/// @param pushSpeed The maximum contact constraint push out speed (meters per second)
/// @note Advanced feature
extern fn b2World_SetContactTuning(world: World, hertz: f32, dampingRatio: f32, pushSpeed: f32) void;

/// Adjust joint tuning parameters
/// @param worldId The world id
/// @param hertz The contact stiffness (cycles per second)
/// @param dampingRatio The contact bounciness with 1 being critical damping (non-dimensional)
/// @note Advanced feature
extern fn b2World_SetJointTuning(world: World, hertz: f32, dampingRatio: f32) void;

/// Set the maximum linear speed. Usually in m/s.
extern fn b2World_SetMaximumLinearSpeed(world: World, maximumLinearSpeed: f32) void;

/// Get the maximum linear speed. Usually in m/s.
extern fn b2World_GetMaximumLinearSpeed(world: World) f32;

/// Enable/disable constraint warm starting. Advanced feature for testing. Disabling
/// sleeping greatly reduces stability and provides no performance gain.
extern fn b2World_EnableWarmStarting(world: World, flag: bool) void;

/// Is constraint warm starting enabled?
extern fn b2World_IsWarmStartingEnabled(world: World) bool;

/// Get the number of awake bodies.
extern fn b2World_GetAwakeBodyCount(world: World) c_int;

/// Get the current world performance profile
extern fn b2World_GetProfile(world: World) Profile;

/// Get world counters and sizes
extern fn b2World_GetCounters(world: World) Counters;

/// Set the user data pointer.
extern fn b2World_SetUserData(world: World, userData: ?*anyopaque) void;

/// Get the user data pointer.
extern fn b2World_GetUserData(world: World) ?*anyopaque;

/// Set the friction callback. Passing NULL resets to default.
extern fn b2World_SetFrictionCallback(world: World, callback: FrictionCallback) void;

/// Set the restitution callback. Passing NULL resets to default.
extern fn b2World_SetRestitutionCallback(world: World, callback: RestitutionCallback) void;

/// Dump memory stats to box2d_memory.txt
extern fn b2World_DumpMemoryStats(world: World) void;

/// This is for internal testing
extern fn b2World_RebuildStaticTree(world: World) void;

/// This is for internal testing
extern fn b2World_EnableSpeculative(world: World, flag: bool) void;

/// @defgroup body Body
/// This is the body API.
/// @{
///
/// Create a rigid body given a definition. No reference to the definition is retained. So you can create the definition
/// on the stack and pass it as a pointer.
/// @code{.c}
/// b2BodyDef bodyDef = b2DefaultBodyDef();
/// myBodyId: Body = b2CreateBody(myWorldId, &bodyDef);
/// @endcode
/// @warning This function is locked during callbacks.
extern fn b2CreateBody(world: World, def: *const Body.Definition) Body;

/// Destroy a rigid body given an id. This destroys all shapes and joints attached to the body.
/// Do not keep references to the associated shapes and joints.
extern fn b2DestroyBody(bodyId: Body) void;

/// Body identifier validation. Can be used to detect orphaned ids. Provides validation for up to 64K allocations.
extern fn b2Body_IsValid(id: Body) void;

/// Get the body type: static, kinematic, or dynamic
extern fn b2Body_GetType(bodyId: Body) Body.Type;

/// Change the body type. This is an expensive operation. This automatically updates the mass
/// properties regardless of the automatic mass setting.
extern fn b2Body_SetType(bodyId: Body, type: Body.Type) void;

/// Set the body name. Up to 31 characters excluding 0 termination.
extern fn b2Body_SetName(bodyId: Body, name: [*]const u8) void;

/// Get the body name. May be null.
extern fn b2Body_GetName(bodyId: Body) [*]const u8;

/// Set the user data for a body
extern fn b2Body_SetUserData(bodyId: Body, userData: ?*anyopaque) void;

/// Get the user data stored in a body
extern fn b2Body_GetUserData(bodyId: Body) ?*anyopaque;

/// Get the world position of a body. This is the location of the body origin.
extern fn b2Body_GetPosition(bodyId: Body) Vec2;

/// Get the world rotation of a body as a cosine/sine pair (complex number)
extern fn b2Body_GetRotation(bodyId: Body) Rot;

/// Get the world transform of a body.
extern fn b2Body_GetTransform(bodyId: Body) Transform;

/// Set the world transform of a body. This acts as a teleport and is fairly expensive.
/// @note Generally you should create a body with then intended transform.
/// @see b2BodyDef::position and b2BodyDef::angle
extern fn b2Body_SetTransform(
    bodyId: Body,
    position: Vec2,
    rotation: Rot,
) void;

/// Get a local point on a body given a world point
extern fn b2Body_GetLocalPoint(bodyId: Body, worldPoint: Vec2) Vec2;

/// Get a world point on a body given a local point
extern fn b2Body_GetWorldPoint(bodyId: Body, localPoint: Vec2) Vec2;

/// Get a local vector on a body given a world vector
extern fn b2Body_GetLocalVector(bodyId: Body, worldVector: Vec2) Vec2;

/// Get a world vector on a body given a local vector
extern fn b2Body_GetWorldVector(bodyId: Body, localVector: Vec2) Vec2;

/// Get the linear velocity of a body's center of mass. Usually in meters per second.
extern fn b2Body_GetLinearVelocity(bodyId: Body) Vec2;

/// Get the angular velocity of a body in radians per second
extern fn b2Body_GetAngularVelocity(bodyId: Body) f32;

/// Set the linear velocity of a body. Usually in meters per second.
extern fn b2Body_SetLinearVelocity(bodyId: Body, linearVelocity: Vec2) void;

/// Set the angular velocity of a body in radians per second
extern fn b2Body_SetAngularVelocity(bodyId: Body, angularVelocity: f32) void;

/// Get the linear velocity of a local point attached to a body. Usually in meters per second.
extern fn b2Body_GetLocalPointVelocity(bodyId: Body, localPoint: Vec2) Vec2;

/// Get the linear velocity of a world point attached to a body. Usually in meters per second.
extern fn b2Body_GetWorldPointVelocity(bodyId: Body, worldPoint: Vec2) Vec2;

/// Apply a force at a world point. If the force is not applied at the center of mass,
/// it will generate a torque and affect the angular velocity. This optionally wakes up the body.
/// The force is ignored if the body is not awake.
/// @param bodyId The body id
/// @param force The world force vector, usually in newtons (N)
/// @param point The world position of the point of application
/// @param wake Option to wake up the body
extern fn b2Body_ApplyForce(bodyId: Body, force: Vec2, point: Vec2, wake: bool) void;

/// Apply a force to the center of mass. This optionally wakes up the body.
/// The force is ignored if the body is not awake.
/// @param bodyId The body id
/// @param force the world force vector, usually in newtons (N).
/// @param wake also wake up the body
extern fn b2Body_ApplyForceToCenter(bodyId: Body, force: Vec2, wake: bool) void;

/// Apply a torque. This affects the angular velocity without affecting the linear velocity.
/// This optionally wakes the body. The torque is ignored if the body is not awake.
/// @param bodyId The body id
/// @param torque about the z-axis (out of the screen), usually in N*m.
/// @param wake also wake up the body
extern fn b2Body_ApplyTorque(bodyId: Body, torque: f32, wake: bool) void;

/// Apply an impulse at a point. This immediately modifies the velocity.
/// It also modifies the angular velocity if the point of application
/// is not at the center of mass. This optionally wakes the body.
/// The impulse is ignored if the body is not awake.
/// @param bodyId The body id
/// @param impulse the world impulse vector, usually in N*s or kg*m/s.
/// @param point the world position of the point of application.
/// @param wake also wake up the body
/// @warning This should be used for one-shot impulses. If you need a steady force,
/// use a force instead, which will work better with the sub-stepping solver.
extern fn b2Body_ApplyLinearImpulse(bodyId: Body, impulse: Vec2, point: Vec2, wake: bool) void;

/// Apply an impulse to the center of mass. This immediately modifies the velocity.
/// The impulse is ignored if the body is not awake. This optionally wakes the body.
/// @param bodyId The body id
/// @param impulse the world impulse vector, usually in N*s or kg*m/s.
/// @param wake also wake up the body
/// @warning This should be used for one-shot impulses. If you need a steady force,
/// use a force instead, which will work better with the sub-stepping solver.
extern fn b2Body_ApplyLinearImpulseToCenter(bodyId: Body, impulse: Vec2, wake: bool) void;

/// Apply an angular impulse. The impulse is ignored if the body is not awake.
/// This optionally wakes the body.
/// @param bodyId The body id
/// @param impulse the angular impulse, usually in units of kg*m*m/s
/// @param wake also wake up the body
/// @warning This should be used for one-shot impulses. If you need a steady force,
/// use a force instead, which will work better with the sub-stepping solver.
extern fn b2Body_ApplyAngularImpulse(bodyId: Body, impulse: f32, wake: bool) void;

/// Get the mass of the body, usually in kilograms
extern fn b2Body_GetMass(bodyId: Body) f32;

/// Get the rotational inertia of the body, usually in kg*m^2
extern fn b2Body_GetRotationalInertia(bodyId: Body) f32;

/// Get the center of mass position of the body in local space
extern fn b2Body_GetLocalCenterOfMass(bodyId: Body) Vec2;

/// Get the center of mass position of the body in world space
extern fn b2Body_GetWorldCenterOfMass(bodyId: Body) Vec2;

/// Override the body's mass properties. Normally this is computed automatically using the
/// shape geometry and density. This information is lost if a shape is added or removed or if the
/// body type changes.
extern fn b2Body_SetMassData(bodyId: Body, massData: MassData) void;

/// Get the mass data for a body
extern fn b2Body_GetMassData(bodyId: Body) MassData;

/// This update the mass properties to the sum of the mass properties of the shapes.
/// This normally does not need to be called unless you called SetMassData to override
/// the mass and you later want to reset the mass.
/// You may also use this when automatic mass computation has been disabled.
/// You should call this regardless of body type.
extern fn b2Body_ApplyMassFromShapes(bodyId: Body) void;

/// Adjust the linear damping. Normally this is set in b2BodyDef before creation.
extern fn b2Body_SetLinearDamping(bodyId: Body, linearDamping: f32) void;

/// Get the current linear damping.
extern fn b2Body_GetLinearDamping(bodyId: Body) void;

/// Adjust the angular damping. Normally this is set in b2BodyDef before creation.
extern fn b2Body_SetAngularDamping(bodyId: Body, angularDamping: f32) void;

/// Get the current angular damping.
extern fn b2Body_GetAngularDamping(bodyId: Body) f32;

/// Adjust the gravity scale. Normally this is set in b2BodyDef before creation.
/// @see b2BodyDef::gravityScale
extern fn b2Body_SetGravityScale(bodyId: Body, gravityScale: f32) void;

/// Get the current gravity scale
extern fn b2Body_GetGravityScale(bodyId: Body) f32;

/// @return true if this body is awake
extern fn b2Body_IsAwake(bodyId: Body) bool;

/// Wake a body from sleep. This wakes the entire island the body is touching.
/// @warning Putting a body to sleep will put the entire island of bodies touching this body to sleep,
/// which can be expensive and possibly unintuitive.
extern fn b2Body_SetAwake(bodyId: Body, awake: bool) void;

/// Enable or disable sleeping for this body. If sleeping is disabled the body will wake.
extern fn b2Body_EnableSleep(bodyId: Body, enableSleep: bool) void;

/// Returns true if sleeping is enabled for this body
extern fn b2Body_IsSleepEnabled(bodyId: Body) bool;

/// Set the sleep threshold, usually in meters per second
extern fn b2Body_SetSleepThreshold(bodyId: Body, sleepThreshold: f32) void;

/// Get the sleep threshold, usually in meters per second.
extern fn b2Body_GetSleepThreshold(bodyId: Body) f32;

/// Returns true if this body is enabled
extern fn b2Body_IsEnabled(bodyId: Body) bool;

/// Disable a body by removing it completely from the simulation. This is expensive.
extern fn b2Body_Disable(bodyId: Body) void;

/// Enable a body by adding it to the simulation. This is expensive.
extern fn b2Body_Enable(bodyId: Body) void;

/// Set this body to have fixed rotation. This causes the mass to be reset in all cases.
extern fn b2Body_SetFixedRotation(bodyId: Body, flag: bool) void;

/// Does this body have fixed rotation?
extern fn b2Body_IsFixedRotation(bodyId: Body) bool;

/// Set this body to be a bullet. A bullet does continuous collision detection
/// against dynamic bodies (but not other bullets).
extern fn b2Body_SetBullet(bodyId: Body, flag: bool) void;

/// Is this body a bullet?
extern fn b2Body_IsBullet(bodyId: Body) bool;

/// Enable/disable contact events on all shapes.
/// @see b2ShapeDef::enableContactEvents
/// @warning changing this at runtime may cause mismatched begin/end touch events
extern fn b2Body_EnableContactEvents(bodyId: Body, flag: bool) void;

/// Enable/disable hit events on all shapes
/// @see b2ShapeDef::enableHitEvents
extern fn b2Body_EnableHitEvents(bodyId: Body, flag: bool) void;

/// Get the world that owns this body
extern fn b2Body_GetWorld(bodyId: Body) World;

/// Get the number of shapes on this body
extern fn b2Body_GetShapeCount(bodyId: Body) c_int;

/// Get the shape ids for all shapes on this body, up to the provided capacity.
/// @returns the number of shape ids stored in the user array
extern fn b2Body_GetShapes(bodyId: Body, shapeArray: *Shape, capacity: c_int) c_int;

/// Get the number of joints on this body
extern fn b2Body_GetJointCount(bodyId: Body) c_int;

/// Get the joint ids for all joints on this body, up to the provided capacity
/// @returns the number of joint ids stored in the user array
extern fn b2Body_GetJoints(bodyId: Body, jointArray: *Joint, capacity: c_int) c_int;

/// Get the maximum capacity required for retrieving all the touching contacts on a body
extern fn b2Body_GetContactCapacity(bodyId: Body) c_int;

/// Get the touching contact data for a body.
/// @note Box2D uses speculative collision so some contact points may be separated.
/// @returns the number of elements filled in the provided array
/// @warning do not ignore the return value, it specifies the valid number of elements
extern fn b2Body_GetContactData(bodyId: Body, contactData: *ContactData, capacity: c_int) c_int;

/// Get the current world AABB that contains all the attached shapes. Note that this may not encompass the body origin.
/// If there are no shapes attached then the returned AABB is empty and centered on the body origin.
extern fn b2Body_ComputeAABB(bodyId: Body) AABB;

/// @defgroup shape Shape
/// Functions to create, destroy, and access.
/// Shapes bind raw geometry to bodies and hold material properties including friction and restitution.
/// @{
///
/// Create a circle shape and attach it to a body. The shape definition and geometry are fully cloned.
/// Contacts are not created until the next time step.
/// @return the shape id for accessing the shape
extern fn b2CreateCircleShape(bodyId: Body, def: *const Shape.Definition, circle: *const Shape.Circle) Shape;

/// Create a line segment shape and attach it to a body. The shape definition and geometry are fully cloned.
/// Contacts are not created until the next time step.
/// @return the shape id for accessing the shape
extern fn b2CreateSegmentShape(bodyId: Body, def: *const Shape.Definition, segment: *const Shape.Segment) Shape;

/// Create a capsule shape and attach it to a body. The shape definition and geometry are fully cloned.
/// Contacts are not created until the next time step.
/// @return the shape id for accessing the shape
extern fn b2CreateCapsuleShape(bodyId: Body, def: *const Shape.Definition, capsule: *const Shape.Capsule) Shape;

/// Create a polygon shape and attach it to a body. The shape definition and geometry are fully cloned.
/// Contacts are not created until the next time step.
/// @return the shape id for accessing the shape
extern fn b2CreatePolygonShape(bodyId: Body, def: *const Shape.Definition, polygon: *const Shape.Polygon) Shape;

/// Destroy a shape. You may defer the body mass update which can improve performance if several shapes on a
/// body are destroyed at once.
/// @see b2Body_ApplyMassFromShapes
extern fn b2DestroyShape(shapeId: Shape, updateBodyMass: bool) void;

/// Shape identifier validation. Provides validation for up to 64K allocations.
extern fn b2Shape_IsValid(id: Shape) bool;

/// Get the type of a shape
extern fn b2Shape_GetType(shapeId: Shape) Shape.Type;

/// Get the id of the body that a shape is attached to
extern fn b2Shape_GetBody(shapeId: Shape) Body;

/// Get the world that owns this shape
extern fn b2Shape_GetWorld(shapeId: Shape) World;

/// Returns true If the shape is a sensor
extern fn b2Shape_IsSensor(shapeId: Shape) bool;

/// Set the user data for a shape
extern fn b2Shape_SetUserData(shapeId: Shape, userData: ?*anyopaque) void;

/// Get the user data for a shape. This is useful when you get a shape id
/// from an event or query.
extern fn b2Shape_GetUserData(shapeId: Shape) ?*anyopaque;

/// Set the mass density of a shape, usually in kg/m^2.
/// This will optionally update the mass properties on the parent body.
/// @see b2ShapeDef::density, b2Body_ApplyMassFromShapes
extern fn b2Shape_SetDensity(shapeId: Shape, density: f32, updateBodyMass: bool) void;

/// Get the density of a shape, usually in kg/m^2
extern fn b2Shape_GetDensity(shapeId: Shape) f32;

/// Set the friction on a shape
/// @see b2ShapeDef::friction
extern fn b2Shape_SetFriction(shapeId: Shape, friction: f32) void;

/// Get the friction of a shape
extern fn b2Shape_GetFriction(shapeId: Shape) f32;

/// Set the shape restitution (bounciness)
/// @see b2ShapeDef::restitution
extern fn b2Shape_SetRestitution(shapeId: Shape, restitution: f32) void;

/// Get the shape restitution
extern fn b2Shape_GetRestitution(shapeId: Shape) f32;

/// Set the shape material identifier
/// @see b2ShapeDef::material
extern fn b2Shape_SetMaterial(shapeId: Shape, material: c_int) void;

/// Get the shape material identifier
extern fn b2Shape_GetMaterial(shapeId: Shape) c_int;

/// Get the shape filter
extern fn b2Shape_GetFilter(shapeId: Shape) Filter;

/// Set the current filter. This is almost as expensive as recreating the shape. This may cause
/// contacts to be immediately destroyed. However contacts are not created until the next world step.
/// Sensor overlap state is also not updated until the next world step.
/// @see b2ShapeDef::filter
extern fn b2Shape_SetFilter(shapeId: Shape, filter: Filter) void;

/// Enable contact events for this shape. Only applies to kinematic and dynamic bodies. Ignored for sensors.
/// @see b2ShapeDef::enableContactEvents
/// @warning changing this at run-time may lead to lost begin/end events
extern fn b2Shape_EnableContactEvents(shapeId: Shape, flag: bool) void;

/// Returns true if contact events are enabled
extern fn b2Shape_AreContactEventsEnabled(shapeId: Shape) bool;

/// Enable pre-solve contact events for this shape. Only applies to dynamic bodies. These are expensive
/// and must be carefully handled due to multithreading. Ignored for sensors.
/// @see b2PreSolveFcn
extern fn b2Shape_EnablePreSolveEvents(shapeId: Shape, flag: bool) void;

/// Returns true if pre-solve events are enabled
extern fn b2Shape_ArePreSolveEventsEnabled(shapeId: Shape) bool;

/// Enable contact hit events for this shape. Ignored for sensors.
/// @see b2WorldDef.hitEventThreshold
extern fn b2Shape_EnableHitEvents(shapeId: Shape, flag: bool) void;

/// Returns true if hit events are enabled
extern fn b2Shape_AreHitEventsEnabled(shapeId: Shape) bool;

/// Test a point for overlap with a shape
extern fn b2Shape_TestPoint(shapeId: Shape, point: Vec2) bool;

/// Ray cast a shape directly
extern fn b2Shape_RayCast(shapeId: Shape, input: *const RayCastInput) CastOutput;

/// Get a copy of the shape's circle. Asserts the type is correct.
extern fn b2Shape_GetCircle(shapeId: Shape) Shape.Circle;

/// Get a copy of the shape's line segment. Asserts the type is correct.
extern fn b2Shape_GetSegment(shapeId: Shape) Shape.Segment;

/// Get a copy of the shape's chain segment. These come from chain shapes.
/// Asserts the type is correct.
extern fn b2Shape_GetChainSegment(shapeId: Shape) Shape.ChainSegment;

/// Get a copy of the shape's capsule. Asserts the type is correct.
extern fn b2Shape_GetCapsule(shapeId: Shape) Shape.Capsule;

/// Get a copy of the shape's convex polygon. Asserts the type is correct.
extern fn b2Shape_GetPolygon(shapeId: Shape) Shape.Polygon;

/// Allows you to change a shape to be a circle or update the current circle.
/// This does not modify the mass properties.
/// @see b2Body_ApplyMassFromShapes
extern fn b2Shape_SetCircle(shapeId: Shape, circle: *const Shape.Circle) void;

/// Allows you to change a shape to be a capsule or update the current capsule.
/// This does not modify the mass properties.
/// @see b2Body_ApplyMassFromShapes
extern fn b2Shape_SetCapsule(shapeId: Shape, capsule: *const Shape.Capsule) void;

/// Allows you to change a shape to be a segment or update the current segment.
extern fn b2Shape_SetSegment(shapeId: Shape, segment: *const Shape.Segment) void;

/// Allows you to change a shape to be a polygon or update the current polygon.
/// This does not modify the mass properties.
/// @see b2Body_ApplyMassFromShapes
extern fn b2Shape_SetPolygon(shapeId: Shape, polygon: *const Shape.Polygon) void;

/// Get the parent chain id if the shape type is a chain segment, otherwise
/// returns b2_nullChainId.
extern fn b2Shape_GetParentChain(shapeId: Shape) Chain;

/// Get the maximum capacity required for retrieving all the touching contacts on a shape
extern fn b2Shape_GetContactCapacity(shapeId: Shape) c_int;

/// Get the touching contact data for a shape. The provided shapeId will be either shapeIdA or shapeIdB on the contact data.
/// @note Box2D uses speculative collision so some contact points may be separated.
/// @returns the number of elements filled in the provided array
/// @warning do not ignore the return value, it specifies the valid number of elements
extern fn b2Shape_GetContactData(shapeId: Shape, contactData: *ContactData, capacity: c_int) c_int;

/// Get the maximum capacity required for retrieving all the overlapped shapes on a sensor shape.
/// This returns 0 if the provided shape is not a sensor.
/// @param shapeId the id of a sensor shape
/// @returns the required capacity to get all the overlaps in b2Shape_GetSensorOverlaps
extern fn b2Shape_GetSensorCapacity(shapeId: Shape) c_int;

/// Get the overlapped shapes for a sensor shape.
/// @param shapeId the id of a sensor shape
/// @param overlaps a user allocated array that is filled with the overlapping shapes
/// @param capacity the capacity of overlappedShapes
/// @returns the number of elements filled in the provided array
/// @warning do not ignore the return value, it specifies the valid number of elements
/// @warning overlaps may contain destroyed shapes so use b2Shape_IsValid to confirm each overlap
extern fn b2Shape_GetSensorOverlaps(shapeId: Shape, overlaps: *Shape, capacity: c_int) c_int;

/// Get the current world AABB
extern fn b2Shape_GetAABB(shapeId: Shape) AABB;

/// Get the mass data for a shape
extern fn b2Shape_GetMassData(shapeId: Shape) MassData;

/// Get the closest point on a shape to a target point. Target and result are in world space.
/// todo need sample
extern fn b2Shape_GetClosestPoint(shapeId: Shape, target: Vec2) Vec2;

/// Chain Shape
/// Create a chain shape
/// @see b2ChainDef for details
extern fn b2CreateChain(bodyId: Body, def: *const Chain.Definition) Chain;

/// Destroy a chain shape
extern fn b2DestroyChain(chainId: Chain) void;

/// Get the world that owns this chain shape
extern fn b2Chain_GetWorld(chainId: Chain) World;

/// Get the number of segments on this chain
extern fn b2Chain_GetSegmentCount(chainId: Chain) c_int;

/// Fill a user array with chain segment shape ids up to the specified capacity. Returns
/// the actual number of segments returned.
extern fn b2Chain_GetSegments(chainId: Chain, segmentArray: *Shape, capacity: c_int) c_int;

/// Set the chain friction
/// @see b2ChainDef::friction
extern fn b2Chain_SetFriction(chainId: Chain, friction: f32) void;

/// Get the chain friction
extern fn b2Chain_GetFriction(chainId: Chain) f32;

/// Set the chain restitution (bounciness)
/// @see b2ChainDef::restitution
extern fn b2Chain_SetRestitution(chainId: Chain, restitution: f32) void;

/// Get the chain restitution
extern fn b2Chain_GetRestitution(chainId: Chain) f32;

/// Set the chain material
/// @see b2ChainDef::material
extern fn b2Chain_SetMaterial(chainId: Chain, material: c_int) void;

/// Get the chain material
extern fn b2Chain_GetMaterial(chainId: Chain) c_int;

/// Chain identifier validation. Provides validation for up to 64K allocations.
extern fn b2Chain_IsValid(id: Chain) bool;

/// @defgroup joint Joint
/// @brief Joints allow you to connect rigid bodies together while allowing various forms of relative motions.
/// @{
///
/// Destroy a joint
extern fn b2DestroyJoint(jointId: Joint) void;

/// Joint identifier validation. Provides validation for up to 64K allocations.
extern fn b2Joint_IsValid(id: Joint) bool;

/// Get the joint type
extern fn b2Joint_GetType(jointId: Joint) Joint.Type;

/// Get body A id on a joint
extern fn b2Joint_GetBodyA(jointId: Joint) Body;

/// Get body B id on a joint
extern fn b2Joint_GetBodyB(jointId: Joint) Body;

/// Get the world that owns this joint
extern fn b2Joint_GetWorld(jointId: Joint) World;

/// Get the local anchor on bodyA
extern fn b2Joint_GetLocalAnchorA(jointId: Joint) Vec2;

/// Get the local anchor on bodyB
extern fn b2Joint_GetLocalAnchorB(jointId: Joint) Vec2;

/// Toggle collision between connected bodies
extern fn b2Joint_SetCollideConnected(jointId: Joint, shouldCollide: bool) void;

/// Is collision allowed between connected bodies?
extern fn b2Joint_GetCollideConnected(jointId: Joint) bool;

/// Set the user data on a joint
extern fn b2Joint_SetUserData(jointId: Joint, userData: ?*anyopaque) void;

/// Get the user data on a joint
extern fn b2Joint_GetUserData(jointId: Joint) ?*anyopaque;

/// Wake the bodies connect to this joint
extern fn b2Joint_WakeBodies(jointId: Joint) void;

/// Get the current constraint force for this joint. Usually in Newtons.
extern fn b2Joint_GetConstraintForce(jointId: Joint) Vec2;

/// Get the current constraint torque for this joint. Usually in Newton * meters.
extern fn b2Joint_GetConstraintTorque(jointId: Joint) f32;

/// @defgroup distance_joint Distance Joint
/// @brief Functions for the distance joint.
/// @{
///
/// Create a distance joint
/// @see b2DistanceJointDef for details
extern fn b2CreateDistanceJoint(world: World, def: *const Joint.Distance.Definition) Joint;

/// Set the rest length of a distance joint
/// @param jointId The id for a distance joint
/// @param length The new distance joint length
extern fn b2DistanceJoint_SetLength(jointId: Joint.Distance, length: f32) void;

/// Get the rest length of a distance joint
extern fn b2DistanceJoint_GetLength(jointId: Joint.Distance) f32;

/// Enable/disable the distance joint spring. When disabled the distance joint is rigid.
extern fn b2DistanceJoint_EnableSpring(jointId: Joint.Distance, enableSpring: bool) void;

/// Is the distance joint spring enabled?
extern fn b2DistanceJoint_IsSpringEnabled(jointId: Joint.Distance) bool;

/// Set the spring stiffness in Hertz
extern fn b2DistanceJoint_SetSpringHertz(jointId: Joint.Distance, hertz: f32) void;

/// Set the spring damping ratio, non-dimensional
extern fn b2DistanceJoint_SetSpringDampingRatio(jointId: Joint.Distance, dampingRatio: f32) void;

/// Get the spring Hertz
extern fn b2DistanceJoint_GetSpringHertz(jointId: Joint.Distance) f32;

/// Get the spring damping ratio
extern fn b2DistanceJoint_GetSpringDampingRatio(jointId: Joint.Distance) f32;

/// Enable joint limit. The limit only works if the joint spring is enabled. Otherwise the joint is rigid
/// and the limit has no effect.
extern fn b2DistanceJoint_EnableLimit(jointId: Joint.Distance, enableLimit: bool) void;

/// Is the distance joint limit enabled?
extern fn b2DistanceJoint_IsLimitEnabled(jointId: Joint.Distance) bool;

/// Set the minimum and maximum length parameters of a distance joint
extern fn b2DistanceJoint_SetLengthRange(jointId: Joint.Distance, minLength: f32, maxLength: f32) void;

/// Get the distance joint minimum length
extern fn b2DistanceJoint_GetMinLength(jointId: Joint.Distance) f32;

/// Get the distance joint maximum length
extern fn b2DistanceJoint_GetMaxLength(jointId: Joint.Distance) f32;

/// Get the current length of a distance joint
extern fn b2DistanceJoint_GetCurrentLength(jointId: Joint.Distance) f32;

/// Enable/disable the distance joint motor
extern fn b2DistanceJoint_EnableMotor(jointId: Joint.Distance, enableMotor: bool) void;

/// Is the distance joint motor enabled?
extern fn b2DistanceJoint_IsMotorEnabled(jointId: Joint.Distance) bool;

/// Set the distance joint motor speed, usually in meters per second
extern fn b2DistanceJoint_SetMotorSpeed(jointId: Joint.Distance, motorSpeed: f32) void;

/// Get the distance joint motor speed, usually in meters per second
extern fn b2DistanceJoint_GetMotorSpeed(jointId: Joint.Distance) f32;

/// Set the distance joint maximum motor force, usually in newtons
extern fn b2DistanceJoint_SetMaxMotorForce(jointId: Joint.Distance, force: f32) void;

/// Get the distance joint maximum motor force, usually in newtons
extern fn b2DistanceJoint_GetMaxMotorForce(jointId: Joint.Distance) f32;

/// Get the distance joint current motor force, usually in newtons
extern fn b2DistanceJoint_GetMotorForce(jointId: Joint.Distance) f32;

/// @defgroup motor_joint Motor Joint
/// @brief Functions for the motor joint.
///
/// The motor joint is used to drive the relative transform between two bodies. It takes
/// a relative position and rotation and applies the forces and torques needed to achieve
/// that relative transform over time.
/// @{
///
/// Create a motor joint
/// @see b2MotorJointDef for details
extern fn b2CreateMotorJoint(world: World, def: *const Joint.Motor.Definition) Joint;

/// Set the motor joint linear offset target
extern fn b2MotorJoint_SetLinearOffset(jointId: Joint.Motor, linearOffset: Vec2) void;

/// Get the motor joint linear offset target
extern fn b2MotorJoint_GetLinearOffset(jointId: Joint.Motor) Vec2;

/// Set the motor joint angular offset target in radians
extern fn b2MotorJoint_SetAngularOffset(jointId: Joint.Motor, angularOffset: f32) void;

/// Get the motor joint angular offset target in radians
extern fn b2MotorJoint_GetAngularOffset(jointId: Joint.Motor) f32;

/// Set the motor joint maximum force, usually in newtons
extern fn b2MotorJoint_SetMaxForce(jointId: Joint.Motor, maxForce: f32) void;

/// Get the motor joint maximum force, usually in newtons
extern fn b2MotorJoint_GetMaxForce(jointId: Joint.Motor) f32;

/// Set the motor joint maximum torque, usually in newton-meters
extern fn b2MotorJoint_SetMaxTorque(jointId: Joint.Motor, maxTorque: f32) void;

/// Get the motor joint maximum torque, usually in newton-meters
extern fn b2MotorJoint_GetMaxTorque(jointId: Joint.Motor) f32;

/// Set the motor joint correction factor, usually in [0, 1]
extern fn b2MotorJoint_SetCorrectionFactor(jointId: Joint.Motor, correctionFactor: f32) void;

/// Get the motor joint correction factor, usually in [0, 1]
extern fn b2MotorJoint_GetCorrectionFactor(jointId: Joint.Motor) f32;

/// @defgroup mouse_joint Mouse Joint
/// @brief Functions for the mouse joint.
///
/// The mouse joint is designed for use in the samples application, but you may find it useful in applications where
/// the user moves a rigid body with a cursor.
/// @{
///
/// Create a mouse joint
/// @see b2MouseJointDef for details
extern fn b2CreateMouseJoint(world: World, def: *const Joint.Mouse.Definition) Joint.Mouse;

/// Set the mouse joint target
extern fn b2MouseJoint_SetTarget(jointId: Joint.Mouse, target: Vec2) void;

/// Get the mouse joint target
extern fn b2MouseJoint_GetTarget(jointId: Joint.Mouse) Vec2;

/// Set the mouse joint spring stiffness in Hertz
extern fn b2MouseJoint_SetSpringHertz(jointId: Joint.Mouse, hertz: f32) void;

/// Get the mouse joint spring stiffness in Hertz
extern fn b2MouseJoint_GetSpringHertz(jointId: Joint.Mouse) f32;

/// Set the mouse joint spring damping ratio, non-dimensional
extern fn b2MouseJoint_SetSpringDampingRatio(jointId: Joint.Mouse, dampingRatio: f32) void;

/// Get the mouse joint damping ratio, non-dimensional
extern fn b2MouseJoint_GetSpringDampingRatio(jointId: Joint.Mouse) f32;

/// Set the mouse joint maximum force, usually in newtons
extern fn b2MouseJoint_SetMaxForce(jointId: Joint.Mouse, maxForce: f32) void;

/// Get the mouse joint maximum force, usually in newtons
extern fn b2MouseJoint_GetMaxForce(jointId: Joint.Mouse) f32;

/// @defgroup null_joint Null Joint
/// @brief Functions for the null joint.
///
/// The null joint is used to disable collision between two bodies. As a side effect of being a joint, it also
/// keeps the two bodies in the same simulation island.
/// @{
///
/// Create a null joint.
/// @see b2NullJointDef for details
extern fn b2CreateNullJoint(world: World, def: *const Joint.Null.Definition) Joint.Null;

/// @defgroup prismatic_joint Prismatic Joint
/// @brief A prismatic joint allows for translation along a single axis with no rotation.
///
/// The prismatic joint is useful for things like pistons and moving platforms, where you want a body to translate
/// along an axis and have no rotation. Also called a *slider* joint.
/// @{
///
/// Create a prismatic (slider) joint.
/// @see b2PrismaticJointDef for details
extern fn b2CreatePrismaticJoint(world: World, def: *const Joint.Prismatic.Definition) Joint.Prismatic;

/// Enable/disable the joint spring.
extern fn b2PrismaticJoint_EnableSpring(jointId: Joint.Prismatic, enableSpring: bool) void;

/// Is the prismatic joint spring enabled or not?
extern fn b2PrismaticJoint_IsSpringEnabled(jointId: Joint.Prismatic) bool;

/// Set the prismatic joint stiffness in Hertz.
/// This should usually be less than a quarter of the simulation rate. For example, if the simulation
/// runs at 60Hz then the joint stiffness should be 15Hz or less.
extern fn b2PrismaticJoint_SetSpringHertz(jointId: Joint.Prismatic, hertz: f32) void;

/// Get the prismatic joint stiffness in Hertz
extern fn b2PrismaticJoint_GetSpringHertz(jointId: Joint.Prismatic) f32;

/// Set the prismatic joint damping ratio (non-dimensional)
extern fn b2PrismaticJoint_SetSpringDampingRatio(jointId: Joint.Prismatic, dampingRatio: f32) void;

/// Get the prismatic spring damping ratio (non-dimensional)
extern fn b2PrismaticJoint_GetSpringDampingRatio(jointId: Joint.Prismatic) f32;

/// Enable/disable a prismatic joint limit
extern fn b2PrismaticJoint_EnableLimit(jointId: Joint.Prismatic, enableLimit: bool) void;

/// Is the prismatic joint limit enabled?
extern fn b2PrismaticJoint_IsLimitEnabled(jointId: Joint.Prismatic) bool;

/// Get the prismatic joint lower limit
extern fn b2PrismaticJoint_GetLowerLimit(jointId: Joint.Prismatic) f32;

/// Get the prismatic joint upper limit
extern fn b2PrismaticJoint_GetUpperLimit(jointId: Joint.Prismatic) f32;

/// Set the prismatic joint limits
extern fn b2PrismaticJoint_SetLimits(jointId: Joint.Prismatic, lower: f32, upper: f32) void;

/// Enable/disable a prismatic joint motor
extern fn b2PrismaticJoint_EnableMotor(jointId: Joint.Prismatic, enableMotor: bool) void;

/// Is the prismatic joint motor enabled?
extern fn b2PrismaticJoint_IsMotorEnabled(jointId: Joint.Prismatic) bool;

/// Set the prismatic joint motor speed, usually in meters per second
extern fn b2PrismaticJoint_SetMotorSpeed(jointId: Joint.Prismatic, motorSpeed: f32) void;

/// Get the prismatic joint motor speed, usually in meters per second
extern fn b2PrismaticJoint_GetMotorSpeed(jointId: Joint.Prismatic) f32;

/// Set the prismatic joint maximum motor force, usually in newtons
extern fn b2PrismaticJoint_SetMaxMotorForce(jointId: Joint.Prismatic, force: f32) void;

/// Get the prismatic joint maximum motor force, usually in newtons
extern fn b2PrismaticJoint_GetMaxMotorForce(jointId: Joint.Prismatic) f32;

/// Get the prismatic joint current motor force, usually in newtons
extern fn b2PrismaticJoint_GetMotorForce(jointId: Joint.Prismatic) f32;

/// Get the current joint translation, usually in meters.
extern fn b2PrismaticJoint_GetTranslation(jointId: Joint.Prismatic) f32;

/// Get the current joint translation speed, usually in meters per second.
extern fn b2PrismaticJoint_GetSpeed(jointId: Joint.Prismatic) f32;

/// @defgroup revolute_joint Revolute Joint
/// @brief A revolute joint allows for relative rotation in the 2D plane with no relative translation.
///
/// The revolute joint is probably the most common joint. It can be used for ragdolls and chains.
/// Also called a *hinge* or *pin* joint.
/// @{
///
/// Create a revolute joint
/// @see b2RevoluteJointDef for details
extern fn b2CreateRevoluteJoint(world: World, def: *Joint.Revolute.Definition) Joint;

/// Enable/disable the revolute joint spring
extern fn b2RevoluteJoint_EnableSpring(jointId: Joint.Revolute, enableSpring: bool) void;

/// It the revolute angular spring enabled?
extern fn b2RevoluteJoint_IsSpringEnabled(jointId: Joint.Revolute) bool;

/// Set the revolute joint spring stiffness in Hertz
extern fn b2RevoluteJoint_SetSpringHertz(jointId: Joint.Revolute, hertz: f32) void;

/// Get the revolute joint spring stiffness in Hertz
extern fn b2RevoluteJoint_GetSpringHertz(jointId: Joint.Revolute) f32;

/// Set the revolute joint spring damping ratio, non-dimensional
extern fn b2RevoluteJoint_SetSpringDampingRatio(jointId: Joint.Revolute, dampingRatio: f32) void;

/// Get the revolute joint spring damping ratio, non-dimensional
extern fn b2RevoluteJoint_GetSpringDampingRatio(jointId: Joint.Revolute) f32;

/// Get the revolute joint current angle in radians relative to the reference angle
/// @see b2RevoluteJointDef::referenceAngle
extern fn b2RevoluteJoint_GetAngle(jointId: Joint.Revolute) f32;

/// Enable/disable the revolute joint limit
extern fn b2RevoluteJoint_EnableLimit(jointId: Joint.Revolute, enableLimit: bool) void;

/// Is the revolute joint limit enabled?
extern fn b2RevoluteJoint_IsLimitEnabled(jointId: Joint.Revolute) bool;

/// Get the revolute joint lower limit in radians
extern fn b2RevoluteJoint_GetLowerLimit(jointId: Joint.Revolute) f32;

/// Get the revolute joint upper limit in radians
extern fn b2RevoluteJoint_GetUpperLimit(jointId: Joint.Revolute) f32;

/// Set the revolute joint limits in radians
extern fn b2RevoluteJoint_SetLimits(jointId: Joint.Revolute, lower: f32, upper: f32) void;

/// Enable/disable a revolute joint motor
extern fn b2RevoluteJoint_EnableMotor(jointId: Joint.Revolute, enableMotor: bool) void;

/// Is the revolute joint motor enabled?
extern fn b2RevoluteJoint_IsMotorEnabled(jointId: Joint.Revolute) bool;

/// Set the revolute joint motor speed in radians per second
extern fn b2RevoluteJoint_SetMotorSpeed(jointId: Joint.Revolute, motorSpeed: f32) void;

/// Get the revolute joint motor speed in radians per second
extern fn b2RevoluteJoint_GetMotorSpeed(jointId: Joint.Revolute) f32;

/// Get the revolute joint current motor torque, usually in newton-meters
extern fn b2RevoluteJoint_GetMotorTorque(jointId: Joint.Revolute) f32;

/// Set the revolute joint maximum motor torque, usually in newton-meters
extern fn b2RevoluteJoint_SetMaxMotorTorque(jointId: Joint.Revolute, torque: f32) void;

/// Get the revolute joint maximum motor torque, usually in newton-meters
extern fn b2RevoluteJoint_GetMaxMotorTorque(jointId: Joint.Revolute) f32;

/// @defgroup weld_joint Weld Joint
/// @brief A weld joint fully constrains the relative transform between two bodies while allowing for springiness
///
/// A weld joint constrains the relative rotation and translation between two bodies. Both rotation and translation
/// can have damped springs.
///
/// @note The accuracy of weld joint is limited by the accuracy of the solver. Long chains of weld joints may flex.
/// @{
///
/// Create a weld joint
/// @see b2WeldJointDef for details
extern fn b2CreateWeldJoint(world: World, def: *const Joint.Weld.Definition) Joint;

/// Get the weld joint reference angle in radians
extern fn b2WeldJoint_GetReferenceAngle(jointId: Joint.Weld) f32;

/// Set the weld joint reference angle in radians, must be in [-pi,pi].
extern fn b2WeldJoint_SetReferenceAngle(jointId: Joint.Weld, angleInRadians: f32) void;

/// Set the weld joint linear stiffness in Hertz. 0 is rigid.
extern fn b2WeldJoint_SetLinearHertz(jointId: Joint.Weld, hertz: f32) void;

/// Get the weld joint linear stiffness in Hertz
extern fn b2WeldJoint_GetLinearHertz(jointId: Joint.Weld) void;

/// Set the weld joint linear damping ratio (non-dimensional)
extern fn b2WeldJoint_SetLinearDampingRatio(jointId: Joint.Weld, dampingRatio: f32) void;

/// Get the weld joint linear damping ratio (non-dimensional)
extern fn b2WeldJoint_GetLinearDampingRatio(jointId: Joint.Weld) f32;

/// Set the weld joint angular stiffness in Hertz. 0 is rigid.
extern fn b2WeldJoint_SetAngularHertz(jointId: Joint.Weld, hertz: f32) void;

/// Get the weld joint angular stiffness in Hertz
extern fn b2WeldJoint_GetAngularHertz(jointId: Joint.Weld) f32;

/// Set weld joint angular damping ratio, non-dimensional
extern fn b2WeldJoint_SetAngularDampingRatio(jointId: Joint.Weld, dampingRatio: f32) void;

/// Get the weld joint angular damping ratio, non-dimensional
extern fn b2WeldJoint_GetAngularDampingRatio(jointId: Joint.Weld) f32;

/// @defgroup wheel_joint Wheel Joint
/// The wheel joint can be used to simulate wheels on vehicles.
///
/// The wheel joint restricts body B to move along a local axis in body A. Body B is free to
/// rotate. Supports a linear spring, linear limits, and a rotational motor.
///
/// Create a wheel joint
/// @see b2WheelJointDef for details
extern fn b2CreateWheelJoint(world: World, def: *const Joint.Wheel.Definition) Joint;

/// Enable/disable the wheel joint spring
extern fn b2WheelJoint_EnableSpring(jointId: Joint, enableSpring: bool) void;

/// Is the wheel joint spring enabled?
extern fn b2WheelJoint_IsSpringEnabled(jointId: Joint) bool;

/// Set the wheel joint stiffness in Hertz
extern fn b2WheelJoint_SetSpringHertz(jointId: Joint, hertz: f32) void;

/// Get the wheel joint stiffness in Hertz
extern fn b2WheelJoint_GetSpringHertz(jointId: Joint) f32;

/// Set the wheel joint damping ratio, non-dimensional
extern fn b2WheelJoint_SetSpringDampingRatio(jointId: Joint, dampingRatio: f32) void;

/// Get the wheel joint damping ratio, non-dimensional
extern fn b2WheelJoint_GetSpringDampingRatio(jointId: Joint) f32;

/// Enable/disable the wheel joint limit
extern fn b2WheelJoint_EnableLimit(jointId: Joint, enableLimit: bool) void;

/// Is the wheel joint limit enabled?
extern fn b2WheelJoint_IsLimitEnabled(jointId: Joint) bool;

/// Get the wheel joint lower limit
extern fn b2WheelJoint_GetLowerLimit(jointId: Joint) f32;

/// Get the wheel joint upper limit
extern fn b2WheelJoint_GetUpperLimit(jointId: Joint) f32;

/// Set the wheel joint limits
extern fn b2WheelJoint_SetLimits(jointId: Joint, lower: f32, upper: f32) void;

/// Enable/disable the wheel joint motor
extern fn b2WheelJoint_EnableMotor(jointId: Joint, enableMotor: bool) void;

/// Is the wheel joint motor enabled?
extern fn b2WheelJoint_IsMotorEnabled(jointId: Joint) bool;

/// Set the wheel joint motor speed in radians per second
extern fn b2WheelJoint_SetMotorSpeed(jointId: Joint, motorSpeed: f32) void;

/// Get the wheel joint motor speed in radians per second
extern fn b2WheelJoint_GetMotorSpeed(jointId: Joint) f32;

/// Set the wheel joint maximum motor torque, usually in newton-meters
extern fn b2WheelJoint_SetMaxMotorTorque(jointId: Joint, torque: f32) void;

/// Get the wheel joint maximum motor torque, usually in newton-meters
extern fn b2WheelJoint_GetMaxMotorTorque(jointId: Joint) f32;

/// Get the wheel joint current motor torque, usually in newton-meters
extern fn b2WheelJoint_GetMotorTorque(jointId: Joint) f32;

// Collision

pub const makeBox = b2MakeBox;
extern fn b2MakeBox(width: f32, height: f32) Shape.Polygon;
