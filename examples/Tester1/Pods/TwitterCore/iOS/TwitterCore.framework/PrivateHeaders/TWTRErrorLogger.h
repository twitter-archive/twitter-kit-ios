/*
 * Copyright (C) 2017 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

/**
 This header is private to the Twitter Core SDK and not exposed for public SDK consumption
 */

/**
 *  Protocol for loggers that support error logging.
 */
@protocol TWTRErrorLogger <NSObject>

/**
 *  Logs that an error was encountered inside our SDK.
 *
 *  @param error        (required) An NSError object describing this error case.
 *  @param errorMessage (required) A message describing the error that occurred.
 */
- (void)didEncounterError:(NSError *)error withMessage:(NSString *)errorMessage;

@end
